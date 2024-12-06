{
  config,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    # do not enable permanently (!) - on demand only
    ./setup-vlans.nix
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    domain = "admin.lan";
    search = ["admin.lan" "infra.lan" "intranet.lan" "iotnet.lan" "lan"];
    nameservers = ["192.168.8.3" "192.168.8.2"]; # modify-here
    timeServers = ["192.168.8.3" "192.168.8.2"]; # modify-here
    enableIPv6 = lib.mkForce false;
    usePredictableInterfaceNames = lib.mkForce false;
    networkmanager.enable = lib.mkForce false;
    wireless.enable = lib.mkForce false;
    defaultGateway = {
      address = "192.168.8.1"; # modify-here
      interface = "intranet";
    };
    proxy = {
      default = "";
      noProxy = "";
    };
    vlans = {
      "infra" = {
        id = 1; # vlan id 1 -> infral.lan (default management trunk)
        interface = "eth0";
      };
      "admin" = {
        id = 4; # vlan id 4 -> admin.lan
        interface = "eth0";
        wakeOnLan = {
          enable = true;
          policy = "magic"; # work from home (pwa/jump-station/bastion)
        };
      };
      "intranet" = {
        id = 8; # vlan id 8 -> intranet.lan
        interface = "eth0";
      };
      "iotnet" = {
        id = 9; # vlan id 9 -> iotnet.lan (internet of things)
        interface = "eth0";
      };
    };
  };
}
