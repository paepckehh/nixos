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
    ente = {
      id = 146;
      name = "ente";
      hostname = infra.ente.name;
      domain = infra.domain.user;
      fqdn = "${infra.ente.hostname}.${infra.ente.domain}";
      url = "https://${infra.ente.fqdn}";
      ip = "${infra.net.user}.${toString infra.ente.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset + infra.ente.id;
      };
    };
  };
in {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.ente = {};
    users = {
      ente = {
        group = "ente";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.ente.namespace}.addresses = [
    {Address = "${infra.ente.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.ente.ip} ${infra.ente.hostname} ${infra.ente.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ente = {
      api = {
        enable = true;
        domain = infra.enten.fqdn;
        enableLocalDB = true;
        nginx.enable = false;
        settings = {
          apps = {
            accounts = config.services.ente.web.domains.accounts;
            cast = config.services.ente.web.domains.cast;
            public-albums = config.services.ente.web.domains.public-albums;
            # XXX TODO
            # https://github.com/ente-io/ente/blob/main/server/configurations/local.yaml
            # key.encryption = "";
            # key.hash = "";
            # key.jwt.secret = "";
          };
        };
      };
      web = {
        enable = true;
        domains = {
          accounts = "accounts-${infra.ente.fqdn}";
          albums = "albums-${infra.ente.fqdn}";
          api = "api-${infra.ente.fqdn}";
          cast = "cast-${infra.ente.fqdn}";
          photos = "photo-${infra.ente.fqdn}";
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.ente.fqdn}".extraConfig = ''
        bind ${infra.ente.ip}
        reverse_proxy ${infra.ente.localbind.ip}:${toString infra.ente.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.ente.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.ente.name}.log
        }'';
    };
  };
}
