# go-mod-proxy
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
  networking.extraHosts = "${infra.go-mod-proxy.ip} ${infra.go-mod-proxy.hostname} ${infra.go-mod-proxy.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.go-mod-proxy.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.go-mod-proxy.fqdn}" = {
      listenAddresses = [infra.go-mod-proxy.ip];
      extraConfig = ''import proxy ${toString infra.infra.go-mod-proxy.localbind.port.http}'';
    };
    go-mod-proxy = {
      enable = true;
      host = infra.localhost.ip;
      port = infra.go-mod-proxy.localbind.port.http;
    };
  };
}
