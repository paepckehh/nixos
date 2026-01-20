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
  networking.extraHosts = "${infra.jellyfin.ip} ${infra.jellyfin.hostname} ${infra.jellyfin.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.jellyfin.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.jellyfin.fqdn}" = {
      listenAddresses = [infra.jellyfin.ip];
      extraConfig = ''import intraproxy ${toString infra.jellyfin.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        jellyfin = {
          image = "jellyfin/jellyfin:latest";
          ports = ["${infra.localhost.ip}:${toString infra.jellyfin.localbind.port.http}:8096"];
          environment = {
            SET_SERVER_NAME = "${infra.jellyfin.fqdn}";
            JELLYFIN_PublishedServerUrl = "${infra.jellyfin.fqdn}";
          };
          volumes = {
            # /config
            # /cache
            # /media
            # /fonts
          };
        };
      };
    };
  };
}
