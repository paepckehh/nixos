# meshtasic web gui lora wan
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

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        meshtastic-web = {
          autoStart = true;
          hostname = infra.meshtastic-web.fqdn;
          image = "gristlabs/grist";
          ports = ["${infra.localhost.ip}:${toString infra.meshtastic-web.localbind.port.http}:8080"];
          environment = {};
        };
      };
    };
  };
}
