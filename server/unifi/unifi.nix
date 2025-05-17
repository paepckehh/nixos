{
  config,
  lib,
  ...
}: {
  ##############################################################################################################
  ##       STRUCTURE   #     DNS         #     AD      #  NETWORK INTERFACE  #   VLANID  #     NETWORK        ##
  ##############################################################################################################
  ## lan               #    lan          #     [-]     #      [native]       #   [-]     #   [10.0.0.0/24]    ##
  ## + infra           #  infra.lan      #     [-]     #      [native]       #   [-]     #   [10.0.0.0/24]    ##
  ## + admin           #  admin.lan      #     [-]     #      [admin]        #   [8]     #   [10.0.8.0/24]    ##
  ## + home            #  home.lan       #   home.lan  #      [server]       #   [16]    #   [10.0.16.0/24]   ##
  ##   +  server       #  home.lan       #   home.lan  #      [server]       #   [16]    #   [10.0.16.0/24]   ##
  ##   +  client       #  home.lan       #   home.lan  #      [client]       #   [128]   #   [10.0.128.0/24]  ##
  ## + iot             #  iot.lan        #     [-]     #      [iot]          #   [250]   #   [10.0.250.0/24]  ##
  ## setup / legacy    #     [-]         #     [-]     #      [setup]        #   [4000]  #   [192.168.0.0/8]  ##
  ##############################################################################################################

  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./unifi-bind.nix
    ./unifi-controller.nix
    ./unifi-prometheus.nix
    ./unifi-kea.nix
    ./unifi-vlans.nix
  ];
  networking = {
    domain = "infra.lan";
    search = ["infra.lan" "client.home.lan" "iot.home.lan" "server.home.lan" "admin.lan" "infra.lan" "lan"];
    nameservers = ["10.0.0.3" "10.0.0.2"];
    timeServers = ["10.0.0.3" "10.0.0.2"];
    enableIPv6 = false;
    useDHCP = false;
    usePredictableInterfaceNames = false;
    networkmanager.enable = lib.mkForce false;
    wireless.enable = false;
    defaultGateway = {
      address = "192.168.80.1"; # legacy
      interface = "setup";
    };
    resolvconf = {
      enable = true;
      useLocalResolver = false;
    };
    interfaces = {
      "eth0".ipv4.addresses = [
        {
          address = "10.0.0.2";
          prefixLength = 32;
        }
        {
          address = "10.0.0.3";
          prefixLength = 32;
        }
        {
          address = "10.0.0.30";
          prefixLength = 24;
        }
        {
          address = "192.168.1.150";
          prefixLength = 24;
        }
      ];
      "setup".ipv4.addresses = [
        {
          address = "192.168.80.2"; # legacy
          prefixLength = 24;
        }
      ];
      "admin".ipv4.addresses = [
        {
          address = "10.0.8.2";
          prefixLength = 32;
        }
        {
          address = "10.0.8.3";
          prefixLength = 32;
        }
        {
          address = "10.0.8.30";
          prefixLength = 24;
        }
      ];
      "server".ipv4.addresses = [
        {
          address = "10.0.16.2";
          prefixLength = 32;
        }
        {
          address = "10.0.16.3";
          prefixLength = 32;
        }
        {
          address = "10.0.16.30";
          prefixLength = 24;
        }
      ];
      "client".ipv4.addresses = [
        {
          address = "10.0.128.2";
          prefixLength = 32;
        }
        {
          address = "10.0.128.3";
          prefixLength = 32;
        }
        {
          address = "10.0.128.30";
          prefixLength = 24;
        }
      ];
      "iot".ipv4.addresses = [
        {
          address = "10.0.250.2";
          prefixLength = 32;
        }
        {
          address = "10.0.250.3";
          prefixLength = 32;
        }
        {
          address = "10.0.250.30";
          prefixLength = 24;
        }
      ];
    };
  };
}
