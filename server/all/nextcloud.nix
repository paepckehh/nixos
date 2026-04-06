# nextcloud, cloud
# user_oidc upstream is still flaky: if needed add parameter via gui again
{
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
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.nextcloud.ip} ${infra.nextcloud.hostname} ${infra.nextcloud.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.nextcloud.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.caddy.virtualHosts = {
    "${infra.cloud.fqdn}" = {
      listenAddresses = [infra.cloud.ip];
      extraConfig = ''redir ${infra.cloud.forward.url}{uri} permanent }'';
    };
    "${infra.nextcloud.fqdn}" = {
      listenAddresses = [infra.nextcloud.ip];
      extraConfig = ''import intraproxy ${toString infra.nextcloud.localbind.port.http}'';
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
    }: {
      #################
      #-=# IMPORTS #=-#
      #################
      imports = [../../client/env.nix];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking.hostName = infra.nextcloud.hostname;

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      environment.etc."init".text = "Fake!26!Init";

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
          package = pkgs.nextcloud33;
          configureRedis = true;
          extraAppsEnable = true;
          hostName = infra.nextcloud.hostname;
          database.createLocally = true;
          settings = {
            mail_smtpmode = "smtp";
            mail_smtphost = infra.smtp.admin.fqdn;
            mail_smtpsecure = "";
          };
          config = {
            adminpassFile = "/etc/init"; # fake init root within container, switch to oidc adm groups only
            dbtype = "mysql";
          };
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
              integration_paperless
              notes
              tasks
              onlyoffice
              polls
              richdocuments
              tables
              user_oidc
              ;
          };
          settings = {
            allow_local_remote_servers = true;
            allow_user_to_change_display_name = false;
            allowed_admin_ranges = infra.cidr.admin;
            auto_logout = false;
            default_phone_region = infra.locale.lang;
            default_timezone = infra.locale.tz;
            hide_login_form = false;
            lost_password_link = false;
            overwriteprotocol = "https";
            remember_login_cookie_lifetime = "60*60*24*90"; # 90 Tage
            session_lifetime = "60*60*24*7"; # 7 Tage
            trusted_domains = [infra.nextcloud.fqdn];
            trusted_proxies = [infra.localhost.cidr infra.cidr.user];
            user_oidc = {
              allow_multiple_user_backends = false;
              clientid = infra.nextcloud.app;
              clientsecret = infra.sso.oidc.secret;
              default_token_endpoint_auth_method = infra.sso.oidc.auth.post;
              discoveryuri = infra.sso.oidc.discoveryUri;
              enrich_login_id_token_with_userinfo = true;
              login_label = infra.sso.prefix;
              provider = infra.sso.app;
            };
            dashboard.layout = "calendar,files,activity";
            enabledPreviewProviders = [
              "OC\\Preview\\Image"
              "OC\\Preview\\Movie"
              "OC\\Preview\\PDF"
              "OC\\Preview\\MSOfficeDoc"
              "OC\\Preview\\MSOffice"
              "OC\\Preview\\Photoshop"
              "OC\\Preview\\SVG"
              "OC\\Preview\\TIFF"
              "OC\\Preview\\HEIC"
            ];
          };
        };
      };
    };
  };
}
