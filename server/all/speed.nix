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
    speed = {
      id = 134;
      name = "speed";
      hostname = infra.speed.name;
      domain = infra.domain.user;
      fqdn = "${infra.speed.hostname}.${infra.speed.domain}";
      ip = "${infra.net.user}.${toString infra.speed.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        port.http = infra.localhostPortOffset + infra.speed.id;
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.speed.namespace}.addresses = [
    {Address = "${infra.speed.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.speed.ip} ${infra.speed.hostname} ${infra.speed.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        speed = {
          image = "openspeedtest/latest:latest";
          ports = ["${infra.speed.localbind.ip}:${toString infra.speed.localbind.port.tcp}:80"];
          environment.SET_SERVER_NAME = "${infra.speed.fqdn}";
        };
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      enable = false;
      virtualHosts."${infra.speed.fqdn}".extraConfig = ''
        bind ${infra.speed.ip}
        reverse_proxy ${infra.speed.localbind.ip}:${toString infra.speed.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.speed.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.speed.name}.log
        }'';
    };
  };
}
