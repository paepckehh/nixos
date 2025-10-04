{
  lib,
  config,
  pkgs,
  ...
}: let
  infra = {
    admin = "admin";
    contact = "it@${infra.smtp.maildomain}";
    localhost = "127.0.0.1";
    localhostPortOffset = 7000;
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
      admin = "${infra.net.user}.${toString infra.id.admin}.0/24";
      user = "${infra.net.user}.${toString infra.id.user}.0/23";
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
    };
    paperless = {
      id = 125;
      name = "paperless";
      hostname = infra.paperless.name;
      domain = infra.domain.user;
      fqdn = "${infra.paperless.hostname}.${infra.paperless.domain}";
      ip = "${infra.net.user}.${toString infra.paperless.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        port.http = infra.localhostPortOffset + infra.paperless.id;
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
      port = infra.paperless.localbind.port.http;
      database.createLocally = true;
      domain = infra.paperless.fqdn;
      passwordFile = config.age.secrets.paperless.path;
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
      exporter = {
        enable = true;
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
