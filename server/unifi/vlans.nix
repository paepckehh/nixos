{config, ...}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    vlans = {
      "admin" = {
        id = 8;
        interface = "eth0";
      };
      "server" = {
        id = 16;
        interface = "eth0";
      };
      "client" = {
        id = 128;
        interface = "eth0";
      };
      "iot" = {
        id = 256;
        interface = "eth0";
      };
      "setup" = {
        id = 4000;
        interface = "eth0";
      };
    };
  };
}
