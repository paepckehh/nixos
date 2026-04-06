# cloud forwarder
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
  # networking.extraHosts = "${infra.cloud.ip} ${infra.cloud.hostname} ${infra.cloud.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.cloud.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.caddy.virtualHosts."${infra.cloud.fqdn}" = {
    listenAddresses = [infra.cloud.ip];
    extraConfig = ''redir ${infra.cloud.forward.url}{uri} permanent'';
  };
}
