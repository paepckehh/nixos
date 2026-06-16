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
  networking.extraHosts = "${infra.rdpgate.user.ip} ${infra.rdpgate.user.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.rdpgate.user.ip}/32";}];

  ####################
  #-=# ENVIROMENT #=-#
  ####################
  environment = {
    etc."rdpgw/user".text = '''';
    systemPackages = [pkgs.rdpgw];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services.caddy.virtualHosts."${infra.rdpgate.user.fqdn}" = {
    listenAddresses = [infra.rdpgate.user.ip];
    extraConfig = ''import intraproxy ${toString infra.rdpgate.user.localbind.port.http}'';
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.rdpgate-user = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    description = "rdpgate-user";
    serviceConfig = {
      ExecStart = "${pkgs.rdpgw}/bin/rdpgw";
      KillMode = "process";
      Restart = "always";
    };
  };
}
