{config, ...}: let
  infra = {
    tz = "Europe/Berlin";
    localhost = {
      name = "localhost";
      ip = "127.0.0.1";
      port = {
        offset = 7000;
        metrics.offset = infra.localhost.port.offset + 1000;
      };
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
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      url = "https://${infra.pki.fqdn}/acme/acme/directory";
    };
    smtp = {
      hostname = "smtp";
      domain = infra.domain.admin;
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
      externalDomain = "debitor.de";
    };
    admin = {
      name = "admin";
      contact = "it@${infra.smtp.externalDomain}";
    };
    ldap = {
      uri = "http://10.20.0.126:3890";
      base = "dc=dbt,dc=corp";
      bind.dn = "cn=bind,ou=persons,${infra.ldap.base}";
    };

    paperless = {
      id = 146;
      name = "paperless";
      hostname = infra.paperless.name;
      domain = infra.domain.user;
      fqdn = "${infra.paperless.hostname}.${infra.paperless.domain}";
      ip = "${infra.net.user}.${toString infra.paperless.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset + infra.paperless.id;
      };
    };
  };
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets.paperless = {
      file = ../../modules/resources/paperless.age;
      owner = "paperless";
      group = "paperless";
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.paperless = {};
    users = {
      paperless = {
        group = "paperless";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # environment.systemPackages = with pkgs; [];

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.paperless.namespace}.addresses = [
    {Address = "${infra.paperless.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.paperless.ip} ${infra.paperless.hostname} ${infra.paperless.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    paperless = {
      enable = true;
      address = infra.paperless.localbind.ip;
      configureTika = true;
      database.createLocally = true;
      domain = infra.paperless.fqdn;
      exporter.enable = true;
      passwordFile = config.age.secrets.paperless.path;
      port = infra.paperless.localbind.port.http;
      settings = {
        PAPERLESS_ADMIN_EMAIL = infra.admin.contact;
        PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = true;
        PAPERLESS_ACCOUNT_EMAIL_VERIFICATION = false;
        PAPERLESS_ACCOUNT_DEFAULT_GROUPS = "user"; # XXX create and configure group user !
        PAPERLESS_TASK_WORKER = 2;
        PAPERLESS_THREADS_PER_WORKER = 6;
        PAPERLESS_TIME_ZONE = infra.tz;
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.paperless.fqdn}".extraConfig = ''
        bind ${infra.paperless.ip}
        reverse_proxy ${infra.paperless.localbind.ip}:${toString infra.paperless.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.paperless.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.paperless.name}.log
        }'';
    };
  };
}
