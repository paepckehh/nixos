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

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman"; # docker
      containers = {
        chef = {
          image = "ghcr.io/gchq/cyberchef:latest";
          ports = ["${infra.localhost.ip}:${toString infra.chef.localbind.port.http}:80"];
          environment.SET_SERVER_NAME = "${infra.chef.fqdn}";
        };
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.chef.fqdn}" = {
      listenAddresses = [infra.chef.ip];
      extraConfig = ''import intraproxy ${toString infra.chef.localbind.port.http}'';
    };
  };
}
