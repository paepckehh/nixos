{
  config,
  lib,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    domain = "admin.lan";
    search = ["admin.lan" "intranet.lan" "iot.lan" "infra.lan" "lan"]; # modify-here
    nameservers = ["192.168.8.3" "192.168.8.2"]; # modify-here
    timeServers = ["192.168.8.3" "192.168.8.2"]; # modify-here
    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;
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
      "admin" = {
        id = 4; # vlan id 4 -> admin.lan
        interface = "eth0";
      };
      "intranet" = {
        id = 8; # vlan id 8 -> intranet.lan
        interface = "eth0";
      };
      "iot" = {
        id = 9; # vlan id 9 -> iotnet.lan (internet of things)
        interface = "eth0";
      };
    };
    # work from home on-demand (pwa/bastion/jump)
    interfaces."admin" = {
      wakeOnLan = {
        enable = true;
        policy = ["secureon"];
      };
    };
  };
}
