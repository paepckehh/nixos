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
  networking.extraHosts = "${infra.rackula.ip} ${infra.rackula.hostname} ${infra.rackula.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.rackula.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.rackula.fqdn}" = {
      listenAddresses = [infra.rackula.ip];
      extraConfig = ''import intraproxy ${toString infra.rackula.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        rackula = {
          image = "ghcr.io/rackulalives/rackula:latest";
          ports = ["${infra.localhost.ip}:${toString infra.rackula.localbind.port.http}:80"];
          environment.SET_SERVER_NAME = "${infra.rackula.fqdn}";
        };
      };
    };
  };
}
