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
  networking.extraHosts = "${infra.rdpgate.admin.ip} ${infra.rdpgate.admin.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.admin}".addresses = [{Address = "${infra.rdpgate.admin.ip}/32";}];

  ####################
  #-=# ENVIROMENT #=-#
  ####################
  environment = {
    etc."rdpgw/adm".text = '''';
    systemPackages = [pkgs.rdpgw];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services.caddy.virtualHosts."${infra.rdpgate.admin.fqdn}" = {
    listenAddresses = [infra.rdpgate.admin.ip];
    extraConfig = ''import intraproxy ${toString infra.rdpgate.admin.localbind.port.http}'';
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.rdpgate-admin = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    description = "rdgate-admin";
    serviceConfig = {
      ExecStart = "${pkgs.rdpgw}/bin/rdpgw";
      KillMode = "process";
      Restart = "always";
    };
  };
}
