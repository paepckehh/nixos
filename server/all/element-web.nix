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
  networking.extraHosts = "${infra.matrix-web.ip} ${infra.matrix-web.hostname} ${infra.matrix-web.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.matrix-web.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.matrix-web.fqdn}" = {
      listenAddresses = [infra.matrix-web.ip];
      extraConfig = ''import intraproxy ${toString infra.matrix-web.localbind.port.http}'';
    };
    nginx = {
      enable = true;
      virtualHosts."${infra.matrix-web.fqdn}" = {
        listen = [
          {
            addr = infra.localhost.ip;
            port = infra.matrix-web.localbind.port.http;
          }
        ];
        root = pkgs.element-web.override {};
      };
    };
  };
}
