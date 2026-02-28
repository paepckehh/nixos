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
  networking.hostName = lib.mkForce infra.srv2.hostname;

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.enable = lib.mkForce infra.srv2.reverseproxy;
    openssh = {
      enable = lib.mkForce infra.srv2.sshd;
      listenAddresses = [{addr = infra.srv2.admin.ip;}];
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    network.networks = {
      "${infra.namespace.admin}".addresses = [{Address = "${infra.srv2.admin.ip}/${toString infra.cidr.netmask}";}];
      "${infra.namespace.user}".addresses = [{Address = "${infra.srv2.user.ip}/${toString infra.cidr.netmask}";}];
    };
  };
}
