{
  pkgs,
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
        nextcloud = {
          ip = "192.168.80.206";
          hostname = "cloud";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7006;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.nextcloud.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.nextcloud.ip} ${infra.lan.services.nextcloud.hostname} ${infra.lan.services.nextcloud.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.nextcloud.ports.tcp];
  };

  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    nextcloud-admin = {
      file = ../../modules/resources/nextcloud-admin.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
      {
        addr = "${infra.lan.services.nextcloud.localbind.ip}";
        port = infra.lan.services.nextcloud.localbind.ports.tcp;
      }
    ];
    nextcloud = {
      enable = true;
      configureRedis = true;
      database.createLocally = true;
      hostName = "${infra.lan.services.nextcloud.hostname}.${infra.lan.domain}";
      config = {
        adminpassFile = config.age.secrets.nextcloud-admin.path;
        adminuser = "admin";
        dbtype = "sqlite";
      };
      settings.overwritehost = "${infra.lan.services.nextcloud.localbind.ip}:${toString infra.lan.services.nextcloud.localbind.ports.tcp}";
    };
    caddy = {
      enable = true;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."cloud.${infra.lan.domain}".extraConfig = ''
        bind ${infra.lan.services.nextcloud.ip}
        reverse_proxy ${infra.lan.services.nextcloud.localbind.ip}:${toString infra.lan.services.nextcloud.localbind.ports.tcp}
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
