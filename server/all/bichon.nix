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
  networking.extraHosts = "${infra.bichon.ip} ${infra.bichon.hostname} ${infra.bichon.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.bichon.ip}/32";}];
    tmpfiles.rules = [
      "d ${infra.storage.state}/${infra.bichon.app} 0750 1000 1000 - -"
      "d ${infra.storage.state}/${infra.bichon.app}/data 0750 1000 1000 - -"
    ];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.bichon.fqdn}" = {
      listenAddresses = [infra.bichon.ip];
      extraConfig = ''import intraproxy ${toString infra.bichon.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        bichon = {
          image = "rustmailer/bichon:latest";
          ports = ["${infra.localhost.ip}:${toString infra.bichon.localbind.port.http}:15630"];
          volumes = ["${infra.storage.state}/${infra.bichon.app}/data:/data"];
          environment = {
            SET_SERVER_NAME = "${infra.bichon.fqdn}";
            BICHON_LOG_LEVEL = "info";
            BICHON_ROOT_DIR = "/data";
          };
        };
      };
    };
  };
}
