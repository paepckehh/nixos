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
    hostName = lib.mkForce "srv";
    # firewall.allowedTCPPorts = [infra.port.ssh];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    openssh = {
      enable = lib.mkForce false;
      listenAddresses = [
        {
          # addr = infra.srv.admin.ip;
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
      "br0".addresses = [{Address = "${infra.srv.bridge.ip}/23";}];
      "admin".addresses = [{Address = "${infra.srv.admin.ip}/23";}];
      "user".addresses = [{Address = "${infra.srv.user.ip}/23";}];
      "remote".addresses = [{Address = "${infra.srv.remote.ip}/23";}];
      "virtual".addresses = [{Address = "${infra.srv.virtual.ip}/23";}];
    };
  };
}
