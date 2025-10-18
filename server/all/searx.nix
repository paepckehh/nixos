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
      uri = "http://10.20.0.126:3890";
      base = "dc=dbt,dc=corp";
      bind.dn = "cn=bind,ou=persons,${infra.ldap.base}";
    };
    search = {
      id = 140;
      name = "search";
      hostname = infra.search.name;
      domain = infra.domain.user;
      fqdn = "${infra.search.hostname}.${infra.search.domain}";
      ip = "${infra.net.user}.${toString infra.search.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        port.http = infra.localhostPortOffset + infra.search.id;
      };
    };
  };
in {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.searx = {};
    users = {
      searx = {
        group = "searx";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.search.namespace}.addresses = [
    {Address = "${infra.search.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.search.ip} ${infra.search.hostname} ${infra.search.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    searx = {
      enable = true;
      redisCreateLocally = false;
      configureUwsgi = false;
      configureNginx = false;
      settings = {
        server = {
          port = infra.search.localbind.port.http;
          bind_address = infra.search.localbind.ip;
          secret_key = "start"; # corp intranet mode
        };
      };
      faviconsSettings = {
        favicons = {
          cfg_schema = 1;
          cache = {
            db_url = "/var/cache/searx/faviconcache.db";
            HOLD_TIME = 5184000;
            LIMIT_TOTAL_BYTES = 2147483648;
            BLOB_MAX_BYTES = 40960;
            MAINTENANCE_MODE = "auto";
            MAINTENANCE_PERIOD = 1200;
          };
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.search.fqdn}".extraConfig = ''
        bind ${infra.search.ip}
        reverse_proxy ${infra.search.localbind.ip}:${toString infra.search.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.search.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.search.name}.log
        }'';
    };
  };
}
