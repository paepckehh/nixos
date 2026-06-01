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
  #-=# ENVIROMENT #=-#
  ####################
  # environment.systemPackages = [pkgs.zdash];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.caddy.virtualHosts."${config.networking.hostName}.${infra.domain.user}" = {
    extraConfig = ''import intraproxy ${toString infra.zdash.localbind.port.http}'';
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.zdash = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    description = "zDash Service";
    environment = {
      BIND_ADDR = "${infra.localhost.ip}:${toString infra.zdash.localbind.port.http}";
    };
    serviceConfig = {
      ExecStart = "/nix/persist/root/bin/zdash";
      KillMode = "process";
      Restart = "always";
    };
  };
}
