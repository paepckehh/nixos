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
  networking.extraHosts = "${infra.proxmox.ip} ${infra.proxmox.hostname} ${infra.proxmox.fqdn}";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    proxmox-ve = {
      enable = true;
      ipAddress = infra.proxmox.ip;
    };
    caddy.virtualHosts."${infra.proxmox.fqdn}" = {
      listenAddresses = [infra.proxmox.ip];
      extraConfig = ''import intraproxy ${toString infra.proxmox.localbind.port.http}'';
    };
  };
}
