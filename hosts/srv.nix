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
  imports = [./srv-defaults.nix];

  ##############
  # NETWORKING #
  ##############
  networking.hostName = lib.mkForce "srv";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    openssh = {
      enable = infra.srv.sshd;
      listenAddresses = [{addr = infra.srv.admin.ip;}];
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    network.networks = {
      "admin".addresses = [{Address = "${infra.srv.admin.ip}/23";}];
      "user".addresses = [{Address = "${infra.srv.user.ip}/23";}];
    };
  };
}
