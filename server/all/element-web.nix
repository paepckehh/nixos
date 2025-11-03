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
    localhostName = "localhost";
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
    matrix-web = {
      id = 129;
      name = "matrix-web";
      alias = "message";
      theme = "dark";
      hostname = infra.matrix-web.name;
      domain = infra.domain.user;
      fqdn = "${infra.matrix-web.hostname}.${infra.matrix-web.domain}";
      ip = "${infra.net.user}.${toString infra.matrix-web.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        port.http = infra.localhostPortOffset + infra.matrix-web.id;
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.matrix-web.namespace}.addresses = [
    {Address = "${infra.matrix-web.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.matrix-web.ip} ${infra.matrix-web.hostname} ${infra.matrix-web.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    nginx = {
      enable = true;
      virtualHosts."${infra.localhostName}" = {
        listen = [
          {
            addr = infra.matrix-web.localbind.ip;
            port = infra.matrix-web.localbind.port.http;
          }
        ];
        root = pkgs.element-web.override {
          conf = {
            default_theme = infra.matrix-web.theme;
          };
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.matrix.fqdn}".extraConfig = ''
        alias ${infra.matrix-web.alias}
        bind ${infra.matrix-web.ip}
        reverse_proxy ${infra.matrix-web.localbind.ip}:${toString infra.matrix-web.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remot_ip ${infra.matrix.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.matrix-web.name}.log
        }'';
    };
  };
}
