{
  lib,
  config,
  ...
}: let
  infra = {
    lan = {
      services = {
        ldap = {
          url = "ldap://${infra.lan.services.ldap.server.host}:${infra.lan.services.ldap.server.port}";
          server = {
            host = "10.20.0.124:3860";
            port = 3860;
          };
        };
        smtp = {
          domain = "mail.corp";
          server = {
            host = "smtp.mail.corp";
            port = 25;
          };
        };
        caldav = {
          admin = "admin";
          ip = "10.20.6.127";
          hostname = "cal";
          domain = "dbt.corp";
          namespace = "06-dbt";
          network = "10.20.6.0/23";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7127;
          };
        };
      };
    };
  };
in {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../packages/agenix.nix
  ];

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      davis = {
        file = ../../modules/resources/davis.age;
        owner = "davis";
        group = "davis";
      };
      davis-app = {
        file = ../../modules/resources/davis-app.age;
        owner = "davis";
        group = "davis";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.davis = {};
    users = {
      davis = {
        group = "davis";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.services.caldav.namespace}.addresses = [{Address = "${infra.lan.services.caldav.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.caldav.ip} ${infra.lan.services.caldav.hostname} ${infra.lan.services.caldav.hostname}.${infra.lan.services.caldav.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.caldav.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    davis = {
      enable = true;
      adminLogin = "${infra.lan.services.caldav.admin}";
      adminPasswordFile = config.age.secrets.davis.path;
      appSecretFile = config.age.secrets.davis-app.path;
      database.createLocally = true;
      mail = {
        dsn = "smtp://calendar:calendar@${infra.lan.services.smtp.server.host}:${toString infra.lan.services.smtp.server.port}";
        inviteFromAddress = "calendar@${infra.lan.services.smtp.domain}";
      };
      config = {
        PUBLIC_CALENDARS_ENABLED = true;
        # LDAP_AUTH_URL = "ldap://10.20.0.124:3860";
        # LDAP_DN_PATTERN = "mail=%u";
        # LDAP_MAIL_ATTRIBUTE = "mail";
        # LDAP_AUTH_USER_AUTOCREATE = false;
        # LDAP_CERTIFICATE_CHECKING_STRATEGY="never";  # never, try, hard, demand, allow
      };
      hostname = "localhost";
      # hostname = "${infra.lan.services.caldav.hostname}.${infra.lan.services.caldav.domain}";
    };
    caddy = {
      enable = false;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."${infra.lan.services.caldav.hostname}.${infra.lan.services.caldav.domain}".extraConfig = ''
        bind ${infra.lan.services.caldav.ip}
        reverse_proxy ${infra.lan.services.caldav.localbind.ip}:${toString infra.lan.services.caldav.localbind.ports.tcp}
        tls pki@adm.corp {
              ca_root /etc/ca.crt
              ca https://pki.adm.corp/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.services.caldav.network}
        }
        respond @not_intranet 403
      '';
    };
  };
}
