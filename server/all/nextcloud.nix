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
  networking = {
    extraHosts = "${infra.cloud.ip} ${infra.cloud.hostname} ${infra.cloud.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapps;
  };

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
      # extraOptions = {
      settings = {
        mail_smtpmode = "smtp";
        mail_smtphost = "smtp.dbt.corp";
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
        default_timezone = infra.site.tz;
        remember_login_cookie_lifetime = "60*60*24*90"; # 90 Tage
        session_lifetime = "60*60*24*7"; # 7 Tage
        session_keepalive = true;
        trusted_domains = ["${infra.cloud.fqdn}"];
        trusted_proxies = ["${infra.cloud.access.cidr}"];
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
