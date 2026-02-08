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
  networking = {
    hostName = lib.mkForce "srv2";
    firewall.allowedTCPPorts = [infra.port.ssh];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    openssh = {
      enable = lib.mkForce true;
      listenAddresses = [
        {
          # addr = infra.srv2.admin.ip;
          addr = "0.0.0.0";
          port = infra.port.ssh;
        }
      ];
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    network.networks = {
      # "br0".addresses = [{Address = "${infra.srv2.bridge.ip}/23";}];
      "admin".addresses = [{Address = "${infra.srv2.admin.ip}/23";}];
      "user".addresses = [{Address = "${infra.srv2.user.ip}/23";}];
    };
  };
}
