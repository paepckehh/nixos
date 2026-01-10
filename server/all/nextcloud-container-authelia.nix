# nextcloud, cloud
# cleanup: stop mysql, redis, php, /var/lib/nextcloud /var/lib/redis-nextcloud /var/lib/mysql
# sso: discovery endpoint https://sso.<domain.tld>/.well-known/openid-configuration
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
  systemd.network.networks."user".addresses = [{Address = "${infra.nextcloud.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.nextcloud.fqdn}" = {
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
      imports = [
        ../../client/env.nix
      ];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking.hostName = infra.nextcloud.hostname;

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      # environment.etc."init".text = "ZDI1N$TE5AAAAIArbsvfd$vfvbbhbgf5gvfvd@dgvQC2gdtQ9qCC54Khfe";
      environment.etc."init".text = "start";

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
        nextcloud = {
          enable = true;
          package = pkgs.nextcloud32;
          configureRedis = true;
          hostName = infra.nextcloud.hostname;
          database.createLocally = true;
          settings = {
            mail_smtpmode = "smtp";
            mail_smtphost = infra.smtp.admin.fqdn;
            mail_smtpsecure = "";
          };
          config = {
            adminpassFile = "/etc/init"; # fake init only, see oidc
            dbtype = "mysql";
          };
          extraAppsEnable = true;
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
              mail
              news
              notes
              tasks
              user_oidc
              onlyoffice
              polls
              richdocuments
              tables
              ;
          };
          settings = {
            allow_local_remote_servers = true; # check;
            overwriteprotocol = "https"; # check
            default_phone_region = "DE"; # check
            auto_logout = false;
            allowed_admin_ranges = infra.cidr.admin;
            default_timezone = infra.locale.tz;
            remember_login_cookie_lifetime = "60*60*24*90"; # 90 Tage
            session_lifetime = "60*60*24*7"; # 7 Tage
            trusted_domains = ["home.corp" "nextcloud.home.corp" "sso.home.corp"];
            trusted_proxies = [infra.localhost.cidr "10.20.6.0/23"];
            allow_user_to_change_display_name = false;
            lost_password_link = "disabled";
            oidc_create_groups = false;
            hide_login_form = true;
            user_oidc = {
              allow_multiple_user_backends = false;
              clientid = infra.nextcloud.app;
              clientsecret = "insecure_secret";
              default_token_endpoint_auth_method = infra.sso.oidc.discoveryUri;
              discoveryuri = infra.sso.oidc.discoveryUri;
              enrich_login_id_token_with_userinfo = true;
              login_label' = "SSO Anmeldung [${infra.sso.app}]";
              provider = infra.sso.app;
            };
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
      };
    };
  };
}
