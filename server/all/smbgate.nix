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
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.smbgate.ip} ${infra.smbgate.hostname} ${infra.smbgate.fqdn}";
    firewall = {
      enable = lib.mkForce true;
      allowPing = lib.mkForce true;
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.namespace.user}.addresses = [{Address = "${infra.smbgate.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      smbd.enable = true;
      nmbd.enable = lib.mkForce false;
      nsswins = lib.mkForce false;
      usershares.enable = lib.mkForce false;
      winbindd.enable = lib.mkForce false;
      settings = {
        global = {
          "server min protocol" = "SMB3_00";
          "server smb encrypt" = "required";
          "server signing" = "mandatory";
          "client signing" = "mandatory";
          "workgroup" = "WORKGROUP";
          "server string" = infra.smbgate.name;
          "netbios name" = infra.smbgate.name;
          "invalid users" = ["me" "root"];
          "passwd program" = "/run/wrappers/bin/passwd %u";
          "security" = "user";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "hosts deny" = "0.0.0.0/0";
          "hosts allow" = infra.cidr.user;
          "interfaces" = "${infra.smbgate.lock.interface} ${infra.cidr.user}";
        };
      };
    };
  };
}
