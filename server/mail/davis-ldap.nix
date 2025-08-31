{
  lib,
  config,
  ...
}: let
  infra = {
    lan = {
      services = {
        smtp = {
          ip = "10.20.0.125";
          port = 25;
          hostname = "smtp";
          domain = "dbt.corp";
          maildomain = "debitor.de";
          fqdn = "${infra.lan.services.smtp.hostname}.${infra.lan.services.smtp.domain}";
        };
        ldap = {
          ip = "10.20.0.126";
          port = 3890;
          hostname = "ldap";
          domain = "dbt.corp";
          url = "ldap://${infra.lan.services.ldap.ip}:${toString infra.lan.services.ldap.port}";
          fqdn = "${infra.lan.services.ldap.hostname}.${infra.lan.services.ldap.domain}";
          # url = "ldap://${infra.lan.services.ldap.fqdn}:${infra.lan.services.ldap.port}";
        };
        dav = {
          admin = "admin";
          ip = "10.20.6.127";
          hostname = "dav";
          domain = "dbt.corp";
          fqdn = "${infra.lan.services.dav.hostname}.${infra.lan.services.dav.domain}";
          namespace = "06-dbt";
          network = "10.20.6.0/23";
          ports.tcp = 80;
          url = "https://${infra.lan.services.dav.fqdn}";
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
  systemd.network.networks.${infra.lan.services.dav.namespace}.addresses = [{Address = "${infra.lan.services.dav.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.dav.ip} ${infra.lan.services.dav.hostname} ${infra.lan.services.dav.fqdn}";
    firewall.allowedTCPPorts = [infra.lan.services.dav.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    davis = {
      enable = true;
      adminLogin = "${infra.lan.services.dav.admin}";
      adminPasswordFile = config.age.secrets.davis.path;
      appSecretFile = config.age.secrets.davis-app.path;
      database.createLocally = true;
      hostname = "${infra.lan.services.dav.fqdn}";
      mail = {
        dsn = "smtp://calendar:calendar@${infra.lan.services.smtp.fqdn}:${toString infra.lan.services.smtp.port}";
        inviteFromAddress = "calendar@${infra.lan.services.smtp.maildomain}";
      };
      config = {
        PUBLIC_CALENDARS_ENABLED = true;
        AUTH_METHOD = lib.mkForce "LDAP";
        LDAP_AUTH_URL = lib.mkForce "${infra.lan.services.ldap.url}";
        LDAP_DN_PATTERN = lib.mkForce "mail=%u";
        LDAP_MAIL_ATTRIBUTE = lib.mkForce "mail";
        LDAP_AUTH_USER_AUTOCREATE = lib.mkForce true;
        LDAP_CERTIFICATE_CHECKING_STRATEGY = lib.mkForce "never"; # never, try, hard, demand, allow
      };
      nginx.listen = [
        {
          addr = "${infra.lan.services.dav.ip}";
          port = infra.lan.services.dav.ports.tcp;
        }
      ];
    };
    caddy = {
      enable = false;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."${infra.lan.services.dav.hostname}.${infra.lan.services.dav.domain}".extraConfig = ''
        bind ${infra.lan.services.dav.ip}
        reverse_proxy ${infra.lan.services.dav.localbind.ip}:${toString infra.lan.services.dav.localbind.ports.tcp}
        tls pki@adm.corp {
              ca_root /etc/ca.crt
              ca https://pki.adm.corp/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.services.dav.network}
        }
        respond @not_intranet 403
      '';
    };
  };
}
