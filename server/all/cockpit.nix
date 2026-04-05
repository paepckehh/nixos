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
