{
  config,
  lib,
  ...
}: let
  infra = {
    admin = "admin";
    contact = {
      name = "IT SERVICE";
      email = "it@${infra.smtp.maildomain}";
    };
    localhost = {
      ip = "127.0.0.1";
      port.offset = 7000;
    };
    id = {
      admin = 0;
      user = 6;
    };
    port = {
      smtp = 25;
      http = 80;
      https = 443;
      webapp = [infra.port.http infra.port.https];
    };
    domain = {
      tld = "corp";
      admin = "adm.${infra.domain.tld}";
      user = "dbt.${infra.domain.tld}";
    };
    cidr = {
      admin = "${infra.net.user}.0/24";
      user = "${infra.net.user}.0/23";
    };
    net = {
      prefix = "10.20";
      admin = "${infra.net.prefix}.${toString infra.id.admin}";
      user = "${infra.net.prefix}.${toString infra.id.user}";
    };
    namespace = {
      admin = "${toString infra.id.admin}";
      user = "${toString infra.id.user}";
    };
    pki = {
      acmeContact = "acme@${infra.pki.fqdn}";
      caFile = "/etc/ca.crt";
      hostname = "pki";
      domain = infra.domain.admin;
      maildomain = "debitor.de";
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      url = "https://${infra.pki.fqdn}/acme/acme/directory";
    };
    smtp = {
      hostname = "smtp";
      domain = infra.domain.admin;
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
      maildomain = "debitor.de";
      port = 25;
    };
    ldap = {
      uri = "http://10.20.0.126:3890";
      base = "dc=dbt,dc=corp";
      bind.dn = "cn=bind,ou=persons,${infra.ldap.base}";
    };
    snipeit = {
      id = 140;
      name = "snipeit";
      hostname = infra.snipeit.name;
      domain = infra.domain.user;
      fqdn = "${infra.snipeit.hostname}.${infra.snipeit.domain}";
      ip = "${infra.net.user}.${toString infra.snipeit.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset + infra.snipeit.id;
      };
    };
  };
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      snipeit = {
        file = ../../modules/resources/snipeit.age;
        owner = "snipeit";
        group = "snipeit";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.snipeit = {};
    users = {
      snipeit = {
        group = "snipeit";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.snipeit.namespace}.addresses = [
    {Address = "${infra.snipeit.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.snipeit.ip} ${infra.snipeit.hostname} ${infra.snipeit.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    snipe-it = {
      enable = true;
      appKeyFile = config.age.secrets.snipeit.path; # head -c 32 /dev/urandom | base64
      # appURL = infra.snipeit.fqdn;
      # hostName = infra.snipeit.localbind.ip;
      config = lib.mkForce {
        APP_ENV = "production";
        APP_DEBUG = false;
        APP_TIMEZONE = "Europe/Berlin";
        APP_LOCALE = "de-DE";
        MAX_RESULTS = 500;
        MAIL_MAILER = "smtp";
        MAIL_HOST = infra.smtp.fqdn;
        MAIL_PORT = infra.smtp.port;
        MAIL_USERNAME = "info";
        MAIL_PASSWORD = "info";
        MAIL_FROM_ADDR = lib.mkForce infra.contact.email;
        MAIL_FROM_NAME = lib.mkForce infra.contact.name;
        MAIL_REPLYTO_ADDR = infra.contact.email;
        MAIL_REPLYTO_NAME = infra.contact.name;
        MAIL_AUTO_EMBED_METHOD = "attachment";
        MAIL_TLS_VERIFY_PEER = false;
      };
      nginx.listen = [
        {
          addr = infra.snipeit.localbind.ip;
          port = infra.snipeit.localbind.port.http;
          ssl = false;
        }
      ];
    };
    caddy = {
      enable = true;
      virtualHosts."${infra.snipeit.fqdn}".extraConfig = ''
        bind ${infra.snipeit.ip}
        reverse_proxy ${infra.snipeit.localbind.ip}:${toString infra.snipeit.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.snipeit.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.snipeit.name}.log
                }'';
    };
  };
}
