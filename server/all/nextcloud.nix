{
  lib,
  infra,
  pkgs,
  ...
}:
lib.mkMerge [
  (import ../../lib/proxy.nix {
    inherit infra;
    name = "nextcloud";
  })
  {
    #####################
    #-=# ENVIRONMENT #=-#
    #####################
    environment = {
      systemPackages = [pkgs.cifs-utils];
      etc."smbkey".text = infra.nextcloud.smbkey;
    };

    #####################
    #-=# FILESYSTEMS #=-#
    #####################
    fileSystems = {
      "/mnt/debsmb/arbeitsebene" = {
        device = "//debsmb.dbt.corp/Arbeitsebene";
        fsType = "cifs";
        options = let
          automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in [
          "${automount_opts}"
          "credentials=/etc/nixos/smb-secrets"
          "uid=nextcloud"
          "gid=nextcloud"
          "file_mode=0770"
          "dir_mode=0770"
        ];
      };
    };

    ####################
    #-=# CONTAINERS #=-#
    ####################
    containers.nextcloud = {
      autoStart = true;
      privateNetwork = false;
      config = {
        config,
        pkgs,
        lib,
        ...
      }: let
        ############################
        #-=# GLOBAL SITE IMPORT #=-#
        ############################
        infra = (import ../../siteconfig/config.nix).infra;
      in {
        #################
        #-=# IMPORTS #=-#
        #################
        imports = [../../client/env.nix];

        ####################
        #-=# NETWORKING #=-#
        ####################
        networking.hostName = infra.nextcloud.hostname;

        #################
        #-=# SYSTEMD #=-#
        #################
        systemd.services.nextcloud-setup = {
          after = ["socket.target"];
          wants = ["socket.target"];
          wantedBy = ["multi-user.target"];
        };

        ##################
        #-=# SERVICES #=-#
        ##################
        services = {
          nginx.virtualHosts."${infra.nextcloud.hostname}" = {
            forceSSL = false;
            enableACME = false;
            listen = [
              {
                addr = infra.localhost.ip;
                port = infra.nextcloud.localbind.port.http;
              }
            ];
          };
          nextcloud = {
            enable = true;
            package = pkgs.nextcloud35;
            configureRedis = true;
            extraAppsEnable = true;
            hostName = infra.nextcloud.hostname;
            database.createLocally = true;
            config.dbtype = "mysql";
            extraApps = {
              inherit
                (config.services.nextcloud.package.packages.apps)
                bookmarks
                calendar
                contacts
                cospend
                deck
                files_retention
                forms
                groupfolders
                notes
                tasks
                polls
                tables
                user_oidc
                ;
            };
            settings = {
              auth.bruteforce.protection.enabled = false; # web:security:bruteforce # occ security:bruteforce:reset 127.0.0.1
              ratelimit.protection.enabled = false;
              maintenance_window_start = 1;
              allow_local_remote_servers = true;
              allow_user_to_change_display_name = true;
              allowed_admin_ranges = infra.cidr.admin;
              auto_logout = false;
              default_phone_region = infra.locale.lang;
              default_timezone = infra.locale.tz;
              hide_login_form = true;
              lost_password_link = false;
              overwriteprotocol = "https";
              overwritehost = infra.nextcloud.fqdn;
              remember_login_cookie_lifetime = "60*60*24*90"; # 90 Tage
              session_lifetime = "60*60*24*7"; # 7 Tage
              trusted_domains = [infra.nextcloud.fqdn];
              trusted_proxies = [infra.localhost.cidr infra.cidr.user];
              mail_domain = "debitor.de";
              mail_from_address = "it";
              mail_smtpmode = "smtp";
              mail_smtphost = "10.20.0.3";
              mail_smtpsecure = "";
              mail_smtpauth = false;
              user_oidc = {
                allow_multiple_user_backends = false;
                clientid = infra.nextcloud.name;
                clientsecret = infra.sso.oidc.secret;
                default_token_endpoint_auth_method = infra.sso.oidc.auth.post;
                discoveryuri = infra.sso.oidc.discoveryUri;
                enrich_login_id_token_with_userinfo = true;
                login_label = infra.sso.prefix;
                provider = infra.sso.app;
              };
              dashboard.layout = "calendar,files,activity";
            };
          };
        };
      };
    };
  }
]
