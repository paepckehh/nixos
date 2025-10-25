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
    vscode = {
      id = 151;
      name = "vscode";
      hostname = infra.vscode.name;
      domain = infra.domain.user;
      fqdn = "${infra.vscode.hostname}.${infra.vscode.domain}";
      ip = "${infra.net.user}.${toString infra.vscode.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset.http + infra.vscode.id;
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.vscode.namespace}.addresses = [
    {Address = "${infra.vscode.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.vscode.ip} ${infra.vscode.hostname} ${infra.vscode.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    openvscode-server = {
      enable = true;
      connectionToken = "";
      host = infra.vscode.localbind.ip;
      port = infra.vscode.localbind.port.http;
      telemetryLevel = null;
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.vscode.fqdn}".extraConfig = ''
        bind ${infra.vscode.ip}
        reverse_proxy ${infra.vscode.localbind.ip}:${toString infra.vscode.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.vscode.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.vscode.name}.log
        }'';
    };
  };
}
