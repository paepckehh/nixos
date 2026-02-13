# meshtastic-web, airtable
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/home.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.meshtastic-web.ip} ${infra.meshtastic-web.hostname} ${infra.meshtastic-web.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.meshtastic-web.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.caddy.virtualHosts."${infra.meshtastic-web.fqdn}" = {
    listenAddresses = [infra.meshtastic-web.ip];
    extraConfig = ''import intraproxy ${toString infra.meshtastic-web.localbind.port.http}'';
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        meshtastic-web = {
          autoStart = true;
          hostname = infra.meshtastic-web.fqdn;
          image = "ghcr.io/meshtastic/web:nightly";
          ports = ["${infra.localhost.ip}:${toString infra.meshtastic-web.localbind.port.http}:8080"];
          environment = {};
        };
      };
    };
  };
}
