{config, ...}: let
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
      maildomain = "debitor.de";
    };
    readeck = {
      id = 130;
      name = "readeck";
      hostname = infra.readeck.name;
      domain = infra.domain.user;
      fqdn = "${infra.readeck.hostname}.${infra.readeck.domain}";
      ip = "${infra.net.user}.${toString infra.readeck.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        ports.http = infra.localhostPortOffset + infra.readeck.id;
      };
    };
  };
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      readeck = {
        file = ../../modules/resources/readeck.age;
        owner = "readeck";
        group = "readeck";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.readeck = {};
    users = {
      readeck = {
        group = "readeck";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.readeck.namespace}.addresses = [
    {Address = "${infra.readeck.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.readeck.ip} ${infra.readeck.hostname} ${infra.readeck.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    readeck = {
      enable = true;
      environmentFile = config.age.secrets.readeck.path;
      settings = {
        main = {
          log_level = "info";
          data_directory = "/var/lib/readeck";
        };
        server = {
          host = infra.readeck.localbind.ip;
          port = infra.readeck.localbind.ports.http;
        };
        database = {
          source = "sqlite3:/var/lib/readeck/db.sqlite";
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.readeck.fqdn}".extraConfig = ''
        bind ${infra.readeck.ip}
        reverse_proxy ${infra.readeck.localbind.ip}:${toString infra.matrix.localbind.ports.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remot_ip ${infra.readeck.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.readeck.name}.log
        }'';
    };
  };
}
