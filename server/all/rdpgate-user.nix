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
  networking.extraHosts = "${infra.rdpgate.user.ip} ${infra.rdpgate.user.hostname} ${infra.rdpgate.user.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.rdpgate.user.ip}/32";}];

  ####################
  #-=# ENVIROMENT #=-#
  ####################
  environment.systemPackages = [pkgs.rdpgw];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.rdpgate.user.fqdn}" = {
      listenAddresses = [infra.rdpgw.ip];
      extraConfig = ''import intraproxy ${toString infra.rdpgate.localbind.port.http}'';
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.rdpgate = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    description = "zDash Service";
    environment.BIND_ADDR = "${infra.localhost.ip}:${toString infra.rdpgate.localbind.port.http}";
    serviceConfig = {
      ExecStart = "${pkgs.rdpgw}/bin/rdpgw";
      KillMode = "process";
      Restart = "always";
    };
  };
}
