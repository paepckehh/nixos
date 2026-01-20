{config, ...}: let
  infra = {
    admin = "admin";
    contact = "it@${infra.smtp.maildomain}";
    localhost = "127.0.0.1";
    localhostPortOffset = 7000;
    localhostPortMetricsOffset = 9000;
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
    secret = {
      id = 141;
      name = "secret";
      hostname = infra.secret.name;
      domain = infra.domain.user;
      fqdn = "${infra.secret.hostname}.${infra.secret.domain}";
      ip = "${infra.net.user}.${toString infra.secret.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        port.http = infra.localhostPortOffset + infra.secret.id;
        port.prometheus = infra.localhostPortMetricsOffset + infra.secret.id;
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.secret.namespace}.addresses = [
    {Address = "${infra.secret.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.secret.ip} ${infra.secret.hostname} ${infra.secret.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    memcached = {
      enable = true;
      maxConnections = 128;
      maxMemory = 512; # mb
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        secret = {
          image = "ghcr.io/paepckehh/yopass-ng:latest";
          cmd = [
            "--address=${infra.secret.localbind.ip}"
            "--port=${infra.secret.localbind.port.http}"
            "--metrics-port=${infra.secret.localbind.port.prometheus}"
            "--database=memcached"
            "--memcached=localhost:11211" # default, hardcoded
          ];
          extraOptions = [
            "--network=host"
          ];
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.secret.fqdn}".extraConfig = ''
        bind ${infra.secret.ip}
        reverse_proxy ${infra.secret.localbind.ip}:${toString infra.secret.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.secret.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.secret.name}.log
        }'';
    };
  };
}
