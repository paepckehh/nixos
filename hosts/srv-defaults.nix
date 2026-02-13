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
    hostName = "srv-default";
    usePredictableInterfaceNames = lib.mkForce true;
    networkmanager = {
      enable = true;
      unmanaged = ["enp*"];
    };
    firewall.allowedTCPPorts = (
      if (config.services.openssh.enable == true)
      then [infra.port.ssh]
      else []
    );
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
      enable = lib.mkDefault false;
      listenAddresses = [];
      settings = {
        AllowGroups = null;
        AllowUsers = ["me"];
        AuthorizedPrincipalsFile = null;
        Ciphers = ["chacha20-poly1305@openssh.com"];
        GatewayPorts = "no";
        KbdInteractiveAuthentication = false;
        KexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
        LogLevel = "INFO"; # INFO, VERBOSE, DEBUG
        Macs = null; # chacha20-poly1305 inherent
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        PrintMotd = false;
        StrictModes = true;
        UseDns = false;
        UsePAM = false;
        X11Forwarding = false;
      };
    };
  };

  ###########
  # SYSTEMD #
  ###########
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
        "dummy0" = {
          netdevConfig = {
            Kind = "dummy";
            Name = "dummy0";
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
      };
      networks = {
        "55-link" = {
          enable = true;
          DHCP = "ipv4";
          matchConfig.Name = "enp1s0f4u2u1"; # "enp1s0f0"; # t640  | "enp1s0f4u2u1"; # usb
          networkConfig = {
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "br0" = {
          enable = true;
          bridgeConfig = {};
          vlan = ["admin-vlan" "user-vlan"];
          matchConfig.Name = "br0";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "172.16.0.1/12";}];
        };
        "dummy0" = {
          enable = true;
          matchConfig.Name = "dummy0";
          networkConfig = {
            Bridge = "br0";
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "172.16.0.2/32";}]; # catch-all-172 rfc1918
        };
        "${infra.namespace.admin}" = {
          enable = true;
          domains = [infra.domain.admin];
          matchConfig.Name = "admin-vlan";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
          linkConfig.ActivationPolicy = "always-up";
        };
        "${infra.namespace.user}" = {
          enable = true;
          domains = [infra.domain.user];
          matchConfig.Name = "user-vlan";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
          linkConfig.ActivationPolicy = "always-up";
        };
      };
    };
  };
}
