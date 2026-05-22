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
  #-=# BOOT #=-#
  ##############
  boot = {
    kernelModules = infra.kernel.whitelist.client ++ ["wireguard"];
    kernelParams = infra.kernel.params.client;
    supportedFilesystems = infra.kernel.fs.client;
    initrd.availableKernelModules = infra.kernel.whitelist.client;
  };

  #######
  # AGE #
  #######
  age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    sudo-rs.wheelNeedsPassword = lib.mkForce true;
    pam.services = {
      login.unixAuth = lib.mkForce true;
      sudo.unixAuth = lib.mkForce false;
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services.openssh.enable = lib.mkForce false;

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
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        # initialHashedPassword = lib.mkForce null; # disable password login, XXX TODO: fix SDDM userID login screen
        initialHashedPassword = lib.mkForce "$y$j9T$kfoRrF1T9PXCFCcDceKWJ1$XBjoA6ExLE5rWFPh3HEx2OkHKSpgg8Tf/50zeM5MJOB";
      };
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    network = {
      enable = true;
      netdevs = {
        "01-admin-vlan" = {
          vlanConfig.Id = infra.vlan.admin;
          netdevConfig = {
            Kind = "vlan";
            Name = "01-admin-vlan";
          };
        };
        "02-user-vlan" = {
          vlanConfig.Id = infra.vlan.user;
          netdevConfig = {
            Kind = "vlan";
            Name = "02-user-vlan";
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
          matchConfig.Name = "01-admin-vlan";
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
          matchConfig.Name = "02-user-vlan";
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
