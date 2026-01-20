# database backup
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.databasement.ip} ${infra.databasement.hostname} ${infra.databasement.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."admin".addresses = [{Address = "${infra.databasement.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.databasement.fqdn}" = {
      listenAddresses = [infra.databasement.ip];
      extraConfig = ''import intraproxy ${toString infra.databasement.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        databasement = {
          image = "davidcrty/databasement:latest";
          ports = ["${infra.localhost.ip}:${toString infra.databasement.localbind.port.http}:2226"];
          environment = {
            SET_SERVER_NAME = "${infra.databasement.fqdn}";
            DB_CONNECTION = "sqlite";
            DB_DATABASE = "/data/database.sqlite";
            ENABLE_QUEUE_WORKER = infra.true;
          };
          volumes = {
            # /data
          };
        };
      };
    };
  };
}
