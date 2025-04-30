{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    wastebin = {
      enable = true;
      stateDir = "/var/stateless/wastebin";
      settings = {
        WASTEBIN_TITLE = "wastbin.lan (stateless)";
        WASTEBIN_MAX_BODY_SIZE = 1024;
        WASTEBIN_HTTP_TIMEOUT = 5;
        WASTEBIN_BASEURL = "http://wastebin.lan";
        WASTEBIN_ADDRESS_PORT = "192.168.8.1:6680";
        WASTEBIN_RUST_LOG = "info";
        WASTEBIN_THEME = "gruvbox";
      };
    };
  };
}
