# nextcloud, cloud
# cleanup: stop mysql, redis, php, /var/lib/nextcloud /var/lib/redis-nextcloud /var/lib/mysql
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
  networking.extraHosts = "${infra.cloud.ip} ${infra.cloud.hostname} ${infra.cloud.fqdn}";

  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    nextcloud-admin = {
      file = ../../modules/resources/nextcloud-admin.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.nextcloud = {};
    users = {
      cloud = {
        group = "nextcloud";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

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
      hostName = infra.cloud.hostname;
      https = true;
      database.createLocally = true;
      settings = {
        mail_smtpmode = "smtp";
        mail_smtphost = infra.smtp.fqdn;
        mail_smtpsecure = "";
      };
      config = {
        adminpassFile = config.age.secrets.nextcloud-admin.path;
        adminuser = "admin";
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
          sociallogin
          onlyoffice
          polls
          richdocuments
          tables
          ;
        # files_mindmap = pkgs.fetchNextcloudApp {
        #  url = "https://github.com/ACTom/files_mindmap/releases/download/v0.0.33/files_mindmap-0.0.33.tar.gz";
        #  hash = "sha256-SRHkK3oaSEBsrQPhjgWy9WSliubYkrOc89lix5O/fZM=";
        #  license = "gpl3";
        # };
      };
      settings = {
        auto_logout = false;
        allowed_admin_ranges = infra.cloud.access.cidr;
        # default_language = infra.site.lang;
        # default_locale = infra.site.lang;
        # default_phone_region = infra.site.lang;
        # session_keepalive = true;
        default_timezone = infra.site.tz;
        remember_login_cookie_lifetime = "60*60*24*90"; # 90 Tage
        session_lifetime = "60*60*24*7"; # 7 Tage
        trusted_domains = ["home.corp" "cloud.home.corp" "sso.home.corp"];
        trusted_proxies = [infra.localhost.cidr];
        allow_user_to_change_display_name = false;
        lost_password_link = "disabled";
        oidc_create_groups = false;
        oidc_login_provider_url = "https://sso.home.corp";
        oidc_login_client_id = "nextcloud";
        oidc_login_client_secret = "insecure_secret";
        oidc_login_auto_redirect = false;
        oidc_login_end_session_redirect = false;
        oidc_login_button_text = "CLOUD-LOGIN";
        oidc_login_hide_password_form = false;
        oidc_login_use_id_token = false;
        oidc_login_attributes = {
          "id" = "preferred_username";
          "name" = "name";
          "mail" = "email";
          "groups" = "groups";
          "is_admin" = "is_nextcloud_admin";
        };
        oidc_login_default_group = "oidc";
        oidc_login_use_external_storage = false;
        oidc_login_scope = "openid profile email groups nextcloud_userinfo";
        oidc_login_proxy_ldap = false;
        oidc_login_disable_registration = false;
        oidc_login_redir_fallback = false;
        oidc_login_tls_verify = false;
        oidc_login_webdav_enabled = false;
        oidc_login_password_authentication = false;
        oidc_login_public_key_caching_time = 86400;
        oidc_login_min_time_between_jwks_requests = 10;
        oidc_login_well_known_caching_time = 86400;
        oidc_login_update_avatar = false;
        oidc_login_code_challenge_method = "S256";
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
    nginx.virtualHosts."${infra.cloud.hostname}" = {
      forceSSL = false;
      enableACME = false;
      listen = [
        {
          addr = infra.localhost.ip;
          port = infra.cloud.localbind.port.http;
        }
      ];
    };
    caddy.virtualHosts."${infra.cloud.fqdn}" = {
      listenAddresses = [infra.cloud.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.cloud.localbind.port.http}
        @not_intranet { not remote_ip ${infra.cloud.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
