{
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [6680];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    wastebin = {
      enable = true;
      # stateDir = "/var/stateless/wastebin";
      settings = {
        WASTEBIN_TITLE = "wastbin.lan 192.168.80.100:6680";
        WASTEBIN_MAX_BODY_SIZE = 1024;
        WASTEBIN_HTTP_TIMEOUT = 5;
        WASTEBIN_BASEURL = "http://192.168.80.100:6680";
        WASTEBIN_ADDRESS_PORT = "192.168.80.100:6680";
        WASTEBIN_THEME = "coldark";
        RUST_LOG = "debug";
      };
    };
  };
}
