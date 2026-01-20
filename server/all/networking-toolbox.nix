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
  networking.extraHosts = "${infra.networking-toolbox.ip} ${infra.networking-toolbox.hostname} ${infra.networking-toolbox.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.networking-toolbox.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.networking-toolbox.fqdn}" = {
      listenAddresses = [infra.networking-toolbox.ip];
      extraConfig = ''import intraproxy ${toString infra.networking-toolbox.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        networking-toolbox = {
          image = "lissy93/networking-toolbox:latest";
          ports = ["${infra.localhost.ip}:${toString infra.networking-toolbox.localbind.port.http}:3000"];
          environment.SET_SERVER_NAME = "${infra.networking-toolbox.fqdn}";
        };
      };
    };
  };
}
