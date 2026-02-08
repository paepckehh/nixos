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
    hostName = "srv";
    usePredictableInterfaceNames = lib.mkForce true;
    networkmanager = {
      enable = true;
      unmanaged = ["enp*"];
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
      enable = lib.mkForce false;
      listenAddresses = [
        {
          addr = infra.srv.admin.ip;
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
          DHCP = "ipv4";
          matchConfig.Name = "enp1s0*";
          # matchConfig.Name = "enp1s0f0"; # t640
          # matchConfig.Name = "enp1s0f4u2u1"; # usb
        };
        "br0" = {
          enable = true;
          bridgeConfig = {};
          vlan = ["admin-vlan" "user-vlan" "remote-vlan" "virtual-vlan"];
          matchConfig.Name = "br0";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv.bridge.ip}/23";}];
        };
        "admin" = {
          enable = true;
          domains = [infra.domain.admin];
          matchConfig.Name = "admin-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv.admin.ip}/23";}];
        };
        "user" = {
          enable = true;
          domains = [infra.domain.user];
          matchConfig.Name = "user-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv.user.ip}/23";}];
        };
        "remote" = {
          enable = false;
          domains = [infra.domain.remote];
          matchConfig.Name = "remote-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv.remote.ip}/23";}];
        };
        "virtual" = {
          enable = true;
          domains = [infra.domain.virtual];
          matchConfig.Name = "virtual-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.srv.virtual.ip}/23";}];
        };
      };
    };
  };
}
