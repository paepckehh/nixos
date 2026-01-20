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
  networking.extraHosts = "${infra.res.ip} ${infra.res.hostname} ${infra.res.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.res.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.res.fqdn}" = {
      listenAddresses = [infra.res.ip];
      extraConfig = ''
        import intra
        root * /var/lib/caddy/res
        file_server browse
      '';
    };
  };
}
