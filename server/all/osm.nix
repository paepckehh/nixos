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
  networking.extraHosts = "${infra.osm.ip} ${infra.osm.hostname} ${infra.osm.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.osm.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.osm.fqdn}" = {
      listenAddresses = [infra.osm.ip];
      extraConfig = ''import intraproxy ${toString infra.osm.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        osm = {
          image = "mediagis/nominatim:5.3";
          ports = ["${infra.localhost.ip}:${toString infra.osm.localbind.port.http}:8001"];
          environment = {
            PBF_URL = "https://download.geofabrik.de/europe/germany-latest.osm.pbf";
            REPLICATION_URL = "https://download.geofabrik.de/europe/germany-updates/";
          };
        };
      };
    };
  };
}
