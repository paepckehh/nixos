{
  lib,
  pkgs,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        read = {
          ip = "192.168.80.201";
          hostname = "read";
          ports.tcp = 443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.read.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.read.ip} ${infra.lan.services.read.hostname} ${infra.lan.services.read.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.read.ports.tcp];
  };

  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    readeck = {
      file = ../../modules/resources/readeck.age;
      owner = "root";
      group = "wheel";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    readeck = {
      enable = true;
      environmentFile = config.age.secrets.readeck.path;
      settings = {
        main = {
          log_level = "info";
          data_directory = "/var/lib/readeck";
        };
        server = {
          host = "127.0.0.1";
          port = 8686;
        };
        database = {
          source = "sqlite3:/var/lib/readeck/db.sqlite";
        };
      };
    };
    caddy = {
      enable = true;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      configFile = pkgs.writeText "CaddyfileReadeck" ''
        read.${config.networking.domain} {
          tls internal
          reverse_proxy ${config.services.readeck.settings.server.host}:${toString config.services.readeck.settings.server.port}
          @not_intranet {
            not remote_ip ${infra.lan.network}
          }
          respond @not_intranet 403
          log {
           output file ${config.services.caddy.logDir}/access/proxy-read.log
          }
        }'';
    };
  };
}
