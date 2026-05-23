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
  ##############
  # NETWORKING #
  ##############
  networking = {
    hostName = lib.mkForce infra.srv.name;
    hostId = lib.mkForce infra.srv.hostID;
  };

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
      "${infra.namespace.admin}" = {
        enable = lib.mkForce true;
        addresses = [{Address = "${infra.srv.admin.ip}/${toString infra.cidr.netmask}";}];
      };
      "${infra.namespace.user}" = {
        enable = lib.mkForce true;
        addresses = [{Address = "${infra.srv.user.ip}/${toString infra.cidr.netmask}";}];
      };
      "${infra.namespace.container}" = {
        enable = lib.mkForce true;
      };
      "${infra.namespace.container}-dummy0" = {
        enable = lib.mkForce true;
      };
    };
  };
}
