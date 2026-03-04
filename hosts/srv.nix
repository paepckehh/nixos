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

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.enable = lib.mkForce infra.srv.reverseproxy;
    openssh = {
      enable = lib.mkForce infra.srv.sshd;
      listenAddresses = [{addr = infra.srv.admin.ip;}];
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
