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
  networking.extraHosts = "${infra.web-check.ip} ${infra.web-check.hostname} ${infra.web-check.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.web-check.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.web-check.fqdn}" = {
      listenAddresses = [infra.web-check.ip];
      extraConfig = ''import intraproxy ${toString infra.web-check.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        web-check = {
          image = "lissy93/web-check:latest";
          ports = ["${infra.localhost.ip}:${toString infra.web-check.localbind.port.http}:3000"];
          environment.SET_SERVER_NAME = "${infra.web-check.fqdn}";
        };
      };
    };
  };
}
