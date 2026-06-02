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
  networking.extraHosts = "${infra.rdpgate.admin.ip} ${infra.rdpgate.admin.hostname} ${infra.rdpgate.admin.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.admin}".addresses = [{Address = "${infra.rdpgate.admin.ip}/32";}];

  ####################
  #-=# ENVIROMENT #=-#
  ####################
  environment.systemPackages = [pkgs.rdpgw];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.rdpgate.admin.fqdn}" = {
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
