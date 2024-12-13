{config, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./unifi/bind.nix
    ./unifi/controller.nix
    ./unifi/prometheus.nix
    ./unifi/kea.nix
    ./unifi/vlans.nix
  ];

  ##########################################################################################################
  ##       STRUCTURE   #     DNS     #     AD      #  NETWORK INTERFACE  #   VLANID  #     NETWORK        ##
  ##########################################################################################################
  ## lan               #    lan      #     [-]     #      [native]       #   [-]     #   [10.0.0.0/24]    ##
  ## + infra           #  infra.lan  #     [-]     #      [native]       #   [-]     #   [10.0.0.0/24]    ##
  ## + admin           #  admin.lan  #     [-]     #      [admin]        #   [8]     #   [10.0.8.0/24]    ##
  ## + home            #  home.lan   #   home.lan  #      [server]       #   [16]    #   [10.0.16.0/24]   ##
  ##   +  server       #  home.lan   #   home.lan  #      [server]       #   [16]    #   [10.0.16.0/24]   ##
  ##   +  client       #  home.lan   #   home.lan  #      [client]       #   [128]   #   [10.0.128.0/24]  ##
  ## iot               #   iot.lan   #     [-]     #      [iot]          #   [250]   #   [10.0.250.0/24]  ##
  ## setup / legacy    #     [-]     #     [-]     #      [setup]        #   [4000]  #   [192.168.0.0/8]  ##
  ##########################################################################################################

  networking = {
    hostName = "nixos-mp-infra";
    domain = "infra.lan";
    search = ["infra.lan" "client.lan" "iot.lan" "server.lan" "admin.lan" "infra.lan" "lan"];
    nameservers = ["10.0.0.3" "10.0.0.2"];
    timeServers = ["10.0.0.3" "10.0.0.2"];
    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;
    usePredictableInterfaceNames = lib.mkForce false;
    networkmanager.enable = lib.mkForce false;
    wireless.enable = lib.mkForce false;
    defaultGateway = {
      address = "10.0.128.1"; # internet via client network
      interface = "client";
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
