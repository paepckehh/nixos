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
  networking.extraHosts = "${infra.erpnext.ip} ${infra.erpnext.hostname} ${infra.erpnext.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.erpnext.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.erpnext.fqdn}" = {
      listenAddresses = [infra.erpnext.ip];
      extraConfig = ''import intraproxy ${toString infra.erpnext.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        erpnext = {
          image = "ghcr.io/erpnextlives/erpnext:latest";
          ports = ["${infra.localhost.ip}:${toString infra.erpnext.localbind.port.http}:80"];
          environment.SET_SERVER_NAME = "${infra.erpnext.fqdn}";
        };
      };
    };
  };
}
