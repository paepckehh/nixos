# res.nix => caddy resources (portal images, certs, ...)
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
  networking.extraHosts = "${infra.ollama01.ip} ${infra.ollama01.hostname} ${infra.ollama01.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."admin".addresses = [{Address = "${infra.ollama01.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ollama = {
      enable = true;
      # host = infra.ollama01.ip;
      # port = infra.ollama01.localbind.port.http;
    };
  };
}
