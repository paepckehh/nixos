{
  lib,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        speed = {
          ip = "192.168.80.218";
          hostname = "speed";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7018;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [
    {Address = "${infra.lan.services.speed.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.speed.ip} ${infra.lan.services.speed.hostname} ${infra.lan.services.speed.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.speed.ports.tcp];
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman"; # docker
      containers = {
        speed = {
          image = "openspeedtest/latest:latest";
          ports = ["${infra.lan.services.speed.localbind.ip}:${toString infra.lan.services.speed.localbind.ports.tcp}:80"];
          environment.SET_SERVER_NAME = "${infra.lan.services.speed.hostname}.${infra.lan.domain}";
        };
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      enable = true;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."speed.${infra.lan.domain}".extraConfig = ''
        bind ${infra.lan.services.speed.ip}
        reverse_proxy ${infra.lan.services.speed.localbind.ip}:${toString infra.lan.services.speed.localbind.ports.tcp}
        tls acme@pki.lan {
              ca_root /etc/ca.crt
              ca https://pki.lan/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/access/proxy-read.log
        }'';
    };
  };
}
