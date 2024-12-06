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
    search = ["admin.lan" "intra.lan" "iot.lan" "lan"];
    nameservers = ["127.0.0.1"];
    timeServers = ["127.0.0.1"];
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
      "admin" = {
        id = 1;
        interface = "eth0";
      };
      "intranet" = {
        id = 8;
        interface = "eth0";
      };
      "iot" = {
        id = 9;
        interface = "eth0";
      };
    };
  };
}
