{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [../role/server.nix];

  ##############
  # NETWORKING #
  ##############
  networking.hostName = lib.mkForce "srv";

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation.docker.enable = true;

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    cockpit.enable = lib.mkForce infra.srv.cockpit;
    caddy.enable = lib.mkForce infra.srv.reverseproxy;
    openssh = {
      enable = lib.mkForce infra.srv.sshd;
      listenAddresses = lib.mkForce [
        {
          addr = infra.srv.admin.ip;
          port = infra.port.ssh-mgmt;
        }
      ];
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    network.networks = {
      "${infra.namespace.admin}".addresses = [{Address = "${infra.srv.admin.ip}/${toString infra.cidr.netmask}";}];
      "${infra.namespace.user}".addresses = [{Address = "${infra.srv.user.ip}/${toString infra.cidr.netmask}";}];
    };
  };
}
