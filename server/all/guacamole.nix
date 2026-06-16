# guacamole messenger
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
  networking.extraHosts = "${infra.guacamole.ip} ${infra.guacamole.hostname} ${infra.guacamole.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.guacamole.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      virtualHosts."${infra.guacamole.externalHostname}" = {
        listenAddresses = [infra.guacamole.ip];
        extraConfig = ''import intraproxy ${toString infra.guacamole.localbind.port.http}'';
      };
    };
    guacamole-client = {
      enable = true;
      enableWebserver = true;
      userMappingXml = null;
      settings = {
        guacd-hostname = infra.localhost.name;
        guacd-port = infra.guacamole.localbind.port.http;
      };
    };
  };
}
