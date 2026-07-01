# smb security gateway
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
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [../../siteconfig/smbgate-mounts.nix];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.smbgate.ip} ${infra.smbgate.hostname} ${infra.smbgate.fqdn}";
    firewall = {
      enable = lib.mkForce true;
      allowPing = lib.mkForce true;
      allowedTCPPorts = [infra.port.smb.tcp];
      allowedUDPPorts = [infra.port.smb.quic];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network.networks.${infra.namespace.user}.addresses = [{Address = "${infra.smbgate.ip}/32";}];
    tmpfiles.rules = infra.smbgate.mountpoints;
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = infra.smbgate.users;
    groups = infra.smbgate.groups;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = [pkgs.cifs-utils];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    samba-wsdd.enable = lib.mkForce false;
    samba = {
      enable = true;
      smbd.enable = true;
      nmbd.enable = lib.mkForce false;
      nsswins = lib.mkForce false;
      usershares.enable = lib.mkForce false;
      winbindd.enable = lib.mkForce false;
      settings.global = infra.smb.global;
    };
  };
}
