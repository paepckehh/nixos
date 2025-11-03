# WEBPKI => MKCERTWEB: web gui for pki cert
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/home.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.webpki.ip} ${infra.webpki.hostname} ${infra.webpki.fqdn}.";

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      "mkcertweb" = {
        file = ../../modules/resources/mkcertweb.age;
        owner = "mkcertweb";
        group = "mkcertweb";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups."mkcertweb" = {};
    users = {
      "mkcertweb" = {
        group = "mkcertweb";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh ssoentication
      };
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        mkcertweb = {
          autoStart = true;
          hostname = infra.webpki.fqdn;
          image = "jeffcaldwellca/mkcertweb:latest";
          ports = ["${infra.localhost.ip}:${toString infra.webpki.localbind.port.http}:3000"];
          environment = {
            # SERVER
            PORT = "3000";
            HTTPS_PORT = "3443";
            ENABLE_HTTPS = "false";
            # Authentication
            ENABLE_AUTH = "true";
            AUTH_USERNAME = "admin";
            AUTH_PASSWORD = "password"; # XXX rage
            SESSION_SECRET = "your-random-secret-token"; # XXX rage
            # OpenID Connect (Optional)
            ENABLE_OIDC = "false";
            OIDC_ISSUER = infra.sso.url.base;
            OIDC_CLIENT_ID = infra.webpki.fqdn;
            OIDC_CLIENT_SECRET = "your-oidc-secret-token"; # XXX
            # Email Notifications
            EMAIL_NOTIFICATIONS_ENABLED = "false";
            SMTP_HOST = infra.smtp.fqdn;
            SMTP_PORT = "${toString infra.smtp.port}";
            SMTP_SECURE = "false";
            SMTP_USER = infra.admin.smtp.id;
            SMTP_PASSWORD = infra.admin.smtp.pwd;
            EMAIL_FROM = infra.admin.email;
            EMAIL_TO = infra.admin.email;
            # Certificate Monitoring
            CERT_MONITORING_ENABLED = "false";
            CERT_CHECK_INTERVAL = "0 8 * * *"; # daily 08:00
            CERT_WARNING_DAYS = "30";
            CERT_CRITICAL_DAYS = "7";
          };
        };
      };
    };
  };

  #################
  #-=# SERVICE #=-#
  #################
  services = {
    caddy.virtualHosts."${infra.webpki.fqdn}" = {
      listenAddresses = [infra.webpki.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.webpki.localbind.port.http}
        @not_intranet { not remote_ip ${infra.webpki.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
