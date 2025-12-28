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
  networking.extraHosts = "${infra.navidrome.ip} ${infra.navidrome.hostname} ${infra.navidrome.fqdn}";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    navidrome = {
      enable = true;
      settings = {
        Address = infra.localhost.ip;
        Port = infra.navidrome.localbind.port.http;
      };
    };
    caddy.virtualHosts."${infra.navidrome.fqdn}" = {
      listenAddresses = [infra.navidrome.ip];
      extraConfig = ''import intraproxy ${toString infra.navidrome.port.http}'';
    };
  };
}
