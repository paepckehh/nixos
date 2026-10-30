{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../role/server.nix
    ../storage/stateless-luks-sequence.nix
    ../configuration.nix
    ../hardware/all.nix
    ../client/addrootCA.nix
    ../client/addCache.nix
    ../person/desktop/mpaepcke.nix
    ../packages/devops-core.nix
    ../packages/desktop/gnome.nix
  ];

  ##############
  # NETWORKING #
  ##############
  networking.hostName = lib.mkForce infra.srv2.hostname;

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    cockpit.enable = lib.mkForce infra.srv2.cockpit;
    caddy.enable = lib.mkForce infra.srv2.reverseproxy;
    openssh = {
      enable = lib.mkForce infra.srv2.sshd;
      listenAddresses = lib.mkForce [
        {
          addr = infra.srv2.admin.ip;
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
      "${infra.namespace.admin}".addresses = [{Address = "${infra.srv2.admin.ip}/${toString infra.cidr.netmask}";}];
      "${infra.namespace.user}".addresses = [{Address = "${infra.srv2.user.ip}/${toString infra.cidr.netmask}";}];
    };
  };
}
