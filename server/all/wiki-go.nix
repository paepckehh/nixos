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
  networking.extraHosts = "${infra.wiki-go.ip} ${infra.wiki-go.hostname} ${infra.wiki-go.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.wiki-go.ip}/32";}];

  ####################
  #-=# ENVIROMENT #=-#
  ####################
  environment.systemPackages = [pkgs.wiki-go];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.caddy.virtualHosts."${config.wiki-go.hostName}.${infra.domain.user}" = {
    extraConfig = ''import intraproxy ${toString infra.wiki-go.localbind.port.http}'';
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.wiki-go = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    description = "wiki-go";
    environment = {
      BIND_ADDR = "${infra.localhost.ip}:${toString infra.wiki-go.localbind.port.http}";
    };
    serviceConfig = {
      ExecStart = "${pkgs.wiki-go}/bin/wiki-go";
      KillMode = "process";
      Restart = "always";
    };
  };
}
