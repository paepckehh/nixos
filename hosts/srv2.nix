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
    hostName = "srv2";
    usePredictableInterfaceNames = lib.mkForce true;
    networkmanager = {
      enable = true;
      unmanaged = ["enp1s0f4u2u1"];
    };
    firewall.allowedTCPPorts = [infra.port.ssh];
  };

  #######
  # AGE #
  #######
  age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [ragenix];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    openssh = {
      enable = lib.mkForce true;
      listenAddresses = [
        {
          addr = infra.srv2.admin.ip;
          port = infra.port.ssh;
        }
      ];
      settings = {
        AllowUsers = ["me"];
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  ###########
  # SYSTEMD #
  ###########
  # networkctl
  # systemctl service-log-level systemd-networkd.service [info|debug]
  systemd = {
    services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug"; # warn, info, debug
    network = {
      enable = true;
      netdevs = {
        "br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
          };
        };
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
        "remote-vlan" = {
          vlanConfig.Id = infra.vlan.remote;
          netdevConfig = {
            Kind = "vlan";
            Name = "remote-vlan";
          };
        };
        "virtual-vlan" = {
          vlanConfig.Id = infra.vlan.virtual;
          netdevConfig = {
            Kind = "vlan";
            Name = "virtual-vlan";
          };
        };
      };
      networks = {
        "link" = {
          enable = true;
          matchConfig.Name = "enp1s0f4u2u1";
          DHCP = "ipv4";
        };
        "br0" = {
          enable = true;
          bridgeConfig = {};
          vlan = ["admin-vlan" "user-vlan" "remote-vlan" "virtual-vlan"];
          matchConfig.Name = "br0";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv2.bridge.ip}/23";}];
        };
        "admin" = {
          enable = true;
          domains = [infra.domain.admin];
          matchConfig.Name = "admin-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv2.admin.ip}/23";}];
        };
        "user" = {
          enable = true;
          domains = [infra.domain.user];
          matchConfig.Name = "user-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv2.user.ip}/23";}];
        };
        "remote" = {
          enable = false;
          domains = [infra.domain.remote];
          matchConfig.Name = "remote-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv2.remote.ip}/23";}];
        };
        "virtual" = {
          enable = true;
          domains = [infra.domain.virtual];
          matchConfig.Name = "virtual-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv2.virtual.ip}/23";}];
        };
      };
    };
  };
}
