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
        chef = {
          ip = "192.168.80.212";
          hostname = "chef";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7012;
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
    {Address = "${infra.lan.services.chef.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.chef.ip} ${infra.lan.services.chef.hostname} ${infra.lan.services.chef.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.chef.ports.tcp];
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman"; # docker
      containers = {
        chef = {
          image = "ghcr.io/gchq/cyberchef:latest";
          ports = ["${infra.lan.services.chef.localbind.ip}:${toString infra.lan.services.chef.localbind.ports.tcp}:80"];
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
      virtualHosts."chef.${infra.lan.domain}".extraConfig = ''
        bind ${infra.lan.services.chef.ip}
        reverse_proxy ${infra.lan.services.chef.localbind.ip}:${toString infra.lan.services.chef.localbind.ports.tcp}
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
