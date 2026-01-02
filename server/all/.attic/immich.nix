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
  networking.extraHosts = "${infra.immich.ip} ${infra.immich.hostname} ${infra.immich.fqdn}";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    immich = {
      enable = true;
      host = infra.localhost.ip;
      port = infra.immich.localbind.port.http;
      settings.server.externalDomain = infra.immich.url;
    };
    caddy.virtualHosts."${infra.immich.fqdn}" = {
      listenAddresses = [infra.immich.ip];
      extraConfig = ''import intraproxy ${toString infra.immich.localbind.port.http}'';
    };
  };
}
