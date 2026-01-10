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
  networking.extraHosts = "${infra.bentopdf.ip} ${infra.bentopdf.hostname} ${infra.bentopdf.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.bentopdf.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.bentopdf.fqdn}" = {
      listenAddresses = [infra.bentopdf.ip];
      extraConfig = ''import intraproxy ${toString infra.bentopdf.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        bentopdf = {
          image = "bentopdf/bentopdf:latest";
          ports = ["${infra.localhost.ip}:${toString infra.bentopdf.localbind.port.http}:80"];
          environment.SET_SERVER_NAME = "${infra.bentopdf.fqdn}";
        };
      };
    };
  };
}
