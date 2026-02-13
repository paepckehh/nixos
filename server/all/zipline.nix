# zipline quick file share
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
  networking.extraHosts = "${infra.zipline.ip} ${infra.zipline.hostname} ${infra.zipline.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.zipline.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.zipline.fqdn}" = {
      listenAddresses = [infra.zipline.ip];
      extraConfig = ''import intraproxy ${toString infra.zipline.localbind.port.http}'';
    };
    zipline = {
      enable = true;
      # environmentFiles = true;
      database.createLocally = true;
      settings = {
        CORE_HOSTNAME = infra.localhost.ip;
        CORE_PORT = infra.zipline.localbind.port.http;
        CORE_SECRET = "vfdsvfdsvfvrVREQVeqvfeqVFvfeqrewqVfeqvfeqvrEQre";
      };
    };
  };
}
