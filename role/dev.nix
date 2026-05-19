# generic dev base setup
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
  imports = [
    ../configuration.nix
    ../client/addrootCA.nix
    ../client/addrootCA-ext.nix
    ../client/addCache.nix
    ../client/addWireguard.nix
    ../client/addOpenSnitch-addDev.nix
    ../packages/devops.nix
  ];

  ##############
  # NETWORKING #
  ##############
  networking = {
    usePredictableInterfaceNames = lib.mkForce true;
    nameservers = [infra.dns.ip];
    networkmanager = {
      enable = true;
      unmanaged = ["enp" "enp*"];
    };
  };

  #######
  # AGE #
  #######
  age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];

  ##################
  #-=# SECURITY #=-#
  ##################
  security.sudo-rs.wheelNeedsPassword = lib.mkForce true;

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    network = {
      enable = true;
      netdevs = {
        "admin-vlan" = {
          vlanConfig.Id = infra.vlan.admin;
          netdevConfig = {
            Kind = "vlan";
            Name = "admin-vlan";
          };
        };
        "user-vlan" = {
          vlanConfig.Id = infra.vlan.user;
          netdevConfig = {
            Kind = "vlan";
            Name = "user-vlan";
          };
        };
      };
      networks = {
        "55-link" = {
          enable = true;
          DHCP = "ipv4";
          matchConfig.Name = "enp1s0f0"; # t640
          networkConfig = {
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "56-link" = {
          enable = true;
          DHCP = "ipv4";
          matchConfig.Name = "enp1s0f4u2u1"; # usb
          networkConfig = {
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.admin}" = {
          enable = true;
          domains = [infra.domain.admin];
          matchConfig.Name = "admin-vlan";
          linkConfig.ActivationPolicy = "always-up";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.user}" = {
          enable = true;
          domains = [infra.domain.user];
          matchConfig.Name = "user-vlan";
          linkConfig.ActivationPolicy = "always-up";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
      };
    };
  };
}
