{
  lib,
  config,
  ...
}: let
  infra = {
    services = {
      chef = {
        net = 6;
        id = 117;
        hostname = "chef";
        domain = "dbt.corp";
        fqdn = "${infra.services.chef.hostname}.${infra.services.chef.domain}";
        ip = "10.20.${toString infra.services.chef.net}.${toString infra.serices.chef.id}";
        network = "10.20.${toString infra.services.chef.net}.0/23";
        namespace = "${toString infra.services.chef.net}";
        ports.web = 443;
        localbind = {
          ip = "127.0.0.1";
          ports.web = 7000 + infra.services.chef.id;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.services.chef.namespace}.addresses = [
    {Address = "${infra.services.chef.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.services.chef.ip} ${infra.services.chef.hostname} ${infra.services.chef.fqdn}";
    firewall.allowedTCPPorts = [infra.lan.services.chef.ports.web];
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
          ports = ["${infra.services.chef.localbind.ip}:${toString infra.services.chef.localbind.ports.web}:80"];
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
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."${infra.services.chef.fqdn}".extraConfig = ''
        bind ${infra.services.chef.ip}
        reverse_proxy ${infra.services.chef.localbind.ip}:${toString infra.services.chef.localbind.ports.web}
        tls acme@pki.adm.corp {
              ca_root /etc/ca.crt
              ca https://pki.adm.corp/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.services.chef.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/access/proxy-read.log
        }'';
    };
  };
}
