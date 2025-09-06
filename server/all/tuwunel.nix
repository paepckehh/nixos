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
    matrix-server = {
      id = 128;
      name = "matrix-server";
      self-register = {
        enable = true;
        password = "start";
      };
      hostname = infra.matrix-server.name;
      domain = infra.domain.user;
      fqdn = "${infra.matrix-server.hostname}.${infra.matrix-server.domain}";
      ip = "${infra.net.user}.${toString infra.matrix-server.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        ports.http = infra.localhostPortOffset + infra.matrix-server.id;
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.matrix-server.namespace}.addresses = [
    {Address = "${infra.matrix-server.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.matrix-server.ip} ${infra.matrix-server.hostname} ${infra.matrix-server.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    matrix-tuwunel = {
      enable = true;
      settings = {
        global = {
          address = [infra.matrix-server.localbind.ip];
          port = [infra.matrix-server.localbind.ports.http];
          server_name = infra.matrix-server.fqdn;
          allow_encryption = true;
          allow_federation = false;
          allow_registration = infra.matrix-server.self-register.enable;
          registration_token = infra.matrix-server.self-register.password;
          rocksdb_compression_algo = "zstd"
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.matrix-server.fqdn}".extraConfig = ''
        bind ${infra.matrix-server.ip}
        reverse_proxy ${infra.matrix-server.localbind.ip}:${toString infra.matrix.localbind.ports.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remot_ip ${infra.matrix-server.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.matrix-server.name}.log
        }'';
    };
  };
}
