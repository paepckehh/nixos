{
  lib,
  pkgs,
  config,
  ...
}: {
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
            not remote_ip 192.168.80.0/24
          }
          respond @not_intranet 403
          log {
           output file ${config.services.caddy.logDir}/access/proxy-read.log
          }
        }'';
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."10-lan".addresses = [{Address = "192.168.80.200/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "192.168.80.200 read read.${config.networking.domain}";
    firewall.allowedTCPPorts = [443];
  };
}
