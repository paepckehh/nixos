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
    stirling = {
      id = 150;
      name = "convert";
      hostname = infra.stirling.name;
      domain = infra.domain.user;
      fqdn = "${infra.stirling.hostname}.${infra.stirling.domain}";
      ip = "${infra.net.user}.${toString infra.stirling.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset.http + infra.stirling.id;
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.stirling.namespace}.addresses = [
    {Address = "${infra.stirling.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.stirling.ip} ${infra.stirling.hostname} ${infra.stirling.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    stirling-pdf = {
      enable = true;
      environment = {
        # INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
        CSRFDISABLED = "true";
        SYSTEM_DEFAULTLOCALE = "de-DE";
        SERVER_PORT = infra.stirling.localbind.port.http;
        SERVER_HOST = infra.stirling.localbind.ip;
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.stirling.fqdn}".extraConfig = ''
        bind ${infra.stirling.ip}
        reverse_proxy ${infra.stirling.localbind.ip}:${toString infra.stirling.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.stirling.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.stirling.name}.log
        }'';
    };
  };
}
