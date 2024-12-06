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
    search = ["admin.lan" "infra.lan" "intranet.lan" "iotnet.lan" "lan"];
    nameservers = ["127.0.0.1"];
    timeServers = ["127.0.0.1"];
    enableIPv6 = lib.mkForce false;
    usePredictableInterfaceNames = lib.mkForce false;
    networkmanager.enable = lib.mkForce false;
    wireless.enable = lib.mkForce false;
    defaultGateway = {
      address = "192.168.8.1";
      interface = "intranet";
    };
    proxy = {
      default = "";
      noProxy = "";
    };
    vlans = {
      "infra" = {
        id = 1;
        interface = "eth0";
      };
      "admin" = {
        id = 4;
        interface = "eth0";
      };
      "intranet" = {
        id = 8;
        interface = "eth0";
      };
      "iotnet" = {
        id = 9;
        interface = "eth0";
      };
    };
  };
}
