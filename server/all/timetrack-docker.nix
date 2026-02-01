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
  networking.extraHosts = "${infra.timetrack.ip} ${infra.timetrack.hostname} ${infra.timetrack.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.timetrack.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.timetrack.fqdn}" = {
      listenAddresses = [infra.timetrack.ip];
      extraConfig = ''import intraproxy ${toString infra.timetrack.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        timetrack = {
          image = "docker.io/openducks/timetrack:latest";
          ports = ["${infra.localhost.ip}:${toString infra.timetrack.localbind.port.http}:80"];
          environment.SET_SERVER_NAME = "${infra.timetrack.fqdn}";
        };
      };
    };
  };
}
