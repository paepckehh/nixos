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
  networking.extraHosts = "${infra.undb.ip} ${infra.undb.hostname} ${infra.undb.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.undb.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.undb.fqdn}" = {
      listenAddresses = [infra.undb.ip];
      extraConfig = ''import intraproxy ${toString infra.undb.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        undb = {
          image = "ghcr.io/undb-io/undb:latest";
          ports = ["${infra.localhost.ip}:${toString infra.undb.localbind.port.http}:3721"];
          environment.SET_SERVER_NAME = "${infra.undb.fqdn}";
        };
      };
    };
  };
}
