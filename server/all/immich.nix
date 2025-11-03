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
    immich = {
      id = 145;
      name = "immich";
      hostname = infra.immich.name;
      domain = infra.domain.user;
      fqdn = "${infra.immich.hostname}.${infra.immich.domain}";
      url = "https://${infra.immich.fqdn}";
      ip = "${infra.net.user}.${toString infra.immich.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset + infra.immich.id;
      };
    };
  };
in {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.immich = {};
    users = {
      immich = {
        group = "immich";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.immich.namespace}.addresses = [
    {Address = "${infra.immich.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.immich.ip} ${infra.immich.hostname} ${infra.immich.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    immich = {
      enable = true;
      host = infra.immich.localbind.ip;
      port = infra.immich.localbind.port.http;
      settings.server.externalDomain = infra.immich.url;
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.immich.fqdn}".extraConfig = ''
        bind ${infra.immich.ip}
        reverse_proxy ${infra.immich.localbind.ip}:${toString infra.immich.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.immich.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.immich.name}.log
        }'';
    };
  };
}
