{
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.firewall.allowedTCPPorts = [7222];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    wastebin = {
      enable = true;
      settings = {
        WASTEBIN_TITLE = "192.168.80.222:7222";
        WASTEBIN_MAX_BODY_SIZE = 10485760;
        WASTEBIN_HTTP_TIMEOUT = 10;
        WASTEBIN_BASEURL = "http://192.168.80.222:7222";
        WASTEBIN_ADDRESS_PORT = "192.168.80.222:7222";
        WASTEBIN_THEME = "monokai";
      };
    };
  };
}
