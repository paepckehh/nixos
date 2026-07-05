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
  networking.extraHosts = "${infra.openpaq.ip} ${infra.openpaq.hostname} ${infra.openpaq.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.openpaq.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.openpaq.fqdn}" = {
      listenAddresses = [infra.openpaq.ip];
      extraConfig = ''import intraproxy ${toString infra.openpaq.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        openpaq = {
          image = "ghcr.io/deniceg/openpaq:latest";
          ports = ["${infra.localhost.ip}:${toString infra.openpaq.localbind.port.http}:8001"];
          environment = {
            CACHE_ENABLED = "false";
            VERSION = "deniceg/openpaq:latest";
            CLICKHOUSE_ENABLED = "false";
            USE_TLS = "false";
            USE_JWT = "false";
            NOMINATIM_ADDRESS = "https://osm.dbt.corp/search";
            LOG_LEVEL = "release"; # debug
            WEBSERVER_LISTEN_ADDRESS = "0.0.0.0:8001";
          };
        };
      };
    };
  };
}
