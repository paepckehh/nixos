{
  config,
  pkgs,
  ...
}: let
  infra = {
    admin = "admin";
    contact = "it@${infra.smtp.maildomain}";
    localhost = {
      ip = "127.0.0.1";
      port.offset = {
        http = 7000;
        app = 8000;
        metrics = 9000;
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
    ldap = {
      id = 144;
      name = "ldap";
      hostname = infra.ldap.name;
      domain = infra.domain.user;
      fqdn = "${infra.ldap.hostname}.${infra.ldap.domain}";
      uri = "http://${infra.fqdn}:3890";
      base = "dc=${infra.domain.user},dc=${infra.domain.tld}";
      bind.dn = "cn=bind,ou=persons,${infra.ldap.base}";
    };
    zammad = {
      id = 150;
      name = "zammad";
      hostname = infra.zammad.name;
      domain = infra.domain.user;
      fqdn = "${infra.zammad.hostname}.${infra.zammad.domain}";
      ip = "${infra.net.user}.${toString infra.zammad.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset.http + infra.zammad.id;
      };
    };
  };
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      zammad-db = {
        file = ../../modules/resources/zammad-db.age;
        owner = infra.zammad.name;
        group = infra.zammad.name;
      };
      zammad-key = {
        file = ../../modules/resources/zammad-key.age;
        owner = infra.zammad.name;
        group = infra.zammad.name;
      };
    };
  };
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.zammad.namespace}.addresses = [
    {Address = "${infra.zammad.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.zammad.ip} ${infra.zammad.hostname} ${infra.zammad.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups."${infra.zammad.name}" = {};
    users = {
      "${infra.zammad.name}" = {
        group = infra.zammad.name;
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
    zammad = {
      enable = true;
      database.createLocally = true;
      host = infra.zammad.localbind.ip;
      port = infra.zammad.localbind.port.http;
      redis.createLocally = true;
      secretKeyBaseFile = config.age.secrets.zammad-key.path;
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.zammad.fqdn}".extraConfig = ''
        bind ${infra.zammad.ip}
        reverse_proxy ${infra.zammad.localbind.ip}:${toString infra.zammad.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.zammad.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.zammad.name}.log
        }'';
    };
  };
}
