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
  networking.extraHosts = "${infra.chef.ip} ${infra.chef.hostname} ${infra.chef.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.chef.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.chef.fqdn}" = {
      listenAddresses = [infra.chef.ip];
      extraConfig = ''import intraproxy ${toString infra.chef.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        chef = {
          image = "ghcr.io/gchq/cyberchef:latest";
          ports = ["${infra.localhost.ip}:${toString infra.chef.localbind.port.http}:80"];
          environment.SET_SERVER_NAME = "${infra.chef.fqdn}";
        };
      };
    };
  };
}
