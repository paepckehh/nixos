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
  networking.extraHosts = "${infra.rdpgw.ip} ${infra.rdpgw.hostname} ${infra.rdpgw.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.rdpgw.ip}/32";}];
  
  ####################
  #-=# ENVIROMENT #=-#
  ####################
  environment.systemPackages = [pkgs.rdpgw];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.rdpgw.fqdn}" = {
      listenAddresses = [infra.rdpgw.ip];
      extraConfig = ''import intraproxy ${toString infra.rdpgw.localbind.port.http}'';
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.rdpgate = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    description = "zDash Service";
    environment.BIND_ADDR = "${infra.localhost.ip}:${toString infra.zdash.localbind.port.http}";
    serviceConfig = {
      ExecStart = "${pkgs.rdpgw}/bin/rdpgw";
      KillMode = "process";
      Restart = "always";
    };
  };
}
