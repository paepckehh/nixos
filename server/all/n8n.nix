{
  config,
  pkgs,
  lib,
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
    n8n = {
      id = 152;
      name = "n8n";
      hostname = infra.n8n.name;
      domain = infra.domain.user;
      fqdn = "${infra.n8n.hostname}.${infra.n8n.domain}";
      ip = "${infra.net.user}.${toString infra.n8n.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset.http + infra.n8n.id;
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.n8n.namespace}.addresses = [
    {Address = "${infra.n8n.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.n8n.ip} ${infra.n8n.hostname} ${infra.n8n.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    n8n = {
      enable = true;
      settings = {
        listenaddress = infra.n8n.localbind.ip;
        port = infra.n8n.localbind.port.http;
        protocol = "http";
        enforce_settings_file_permissions = true;
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.n8n.fqdn}".extraConfig = ''
        bind ${infra.n8n.ip}
        reverse_proxy ${infra.n8n.localbind.ip}:${toString infra.n8n.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.n8n.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.n8n.name}.log
        }'';
    };
  };
}
