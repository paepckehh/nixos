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
    authelia.instances."${infra.sso.site}".settings.identity_providers.oidc.clients = [
      {
        client_id = "nextcloud";
        client_name = "nextcloud";
        client_secret = "$pbkdf2-sha512$310000$c8p78n7pUMln0jzvd4aK4Q$JNRBzwAo0ek5qKn50cFzzvE9RXV88h1wJn5KGiHrD0YKtZaR/nCb2CJPOsKaPK0hjf.9yHxzQGZziziccp6Yng"; # 'insecure_secret'
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = ["https://cloud.home.corp/apps/user_oidc/code"];
        scopes = ["openid" "profile" "email" "groups"];
        response_types = "code";
        grant_types = "authorization_code";
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_post";
      }
    ];
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;
      configureRedis = true;
      hostName = infra.cloud.hostname;
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
        allowed_admin_ranges = infra.cloud.access.cidr;
        default_timezone = infra.site.tz;
        remember_login_cookie_lifetime = "60*60*24*90"; # 90 Tage
        session_lifetime = "60*60*24*7"; # 7 Tage
        trusted_domains = ["home.corp" "cloud.home.corp" "sso.home.corp"];
        trusted_proxies = [infra.localhost.cidr "10.20.6.0/23"];
        allow_user_to_change_display_name = false;
        lost_password_link = "disabled";
        oidc_create_groups = false;
        user_oidc = {
          default_token_endpoint_auth_method = "client_secret_post";
          provider = "authelia";
          clientid = "nextcloud";
          clientsecret = "insecure_secret";
          discoveryuri = "https://sso.home.corp/.well-known/openid-configuration";
          login_label' = "SSO Anmeldung";
          enrich_login_id_token_with_userinfo = true;
          allow_multiple_user_backends = false;
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
