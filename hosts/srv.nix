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
    usePredictableInterfaceNames = lib.mkForce true;
    networkmanager = {
      enable = true;
      unmanaged = ["enp1s0f4u2u1"];
    };
  };

  ###########
  # SYSTEMD #
  ###########
  # networkctl
  # systemctl service-log-level systemd-networkd.service info
  # systemctl service-log-level systemd-networkd.service debug
  systemd = {
    services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug"; # warn, info, debug
    network = {
      enable = true;
      netdevs = {
        "lo-br0" = {
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
        "local-br0" = {
          matchConfig.Name = "br0";
          bridgeConfig = {};
          vlan = ["admin-vlan" "user-vlan" "remote-vlan" "virtual-vlan"];
        };
        "admin" = {
          enable = true;
          domains = [infra.domain.admin];
          matchConfig.Name = "admin-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          addresses = [{Address = "${infra.srv.admin.ip}/23";}];
        };
        "user" = {
          enable = true;
          domains = [infra.domain.user];
          matchConfig.Name = "user-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          addresses = [{Address = "${infra.srv.user.ip}/23";}];
        };
        "remote" = {
          enable = false;
          domains = [infra.domain.remote];
          matchConfig.Name = "remote-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          addresses = [{Address = "${infra.srv.remote.ip}/23";}];
        };
        "virtual" = {
          enable = false;
          domains = [infra.domain.virtual];
          matchConfig.Name = "virtual-vlan";
          networkConfig.ConfigureWithoutCarrier = true;
          addresses = [{Address = "${infra.srv.virtual.ip}/23";}];
        };
      };
    };
  };
}
