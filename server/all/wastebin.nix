{
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.firewall.allowedTCPPorts = [2222];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    wastebin = {
      enable = true;
      settings = {
        WASTEBIN_TITLE = "10.20.0.222:2222";
        WASTEBIN_MAX_BODY_SIZE = 10485760;
        WASTEBIN_HTTP_TIMEOUT = 10;
        WASTEBIN_BASEURL = "http://10.20.0.222:2222";
        WASTEBIN_ADDRESS_PORT = "10.20.0.222:2222";
        WASTEBIN_THEME = "monokai";
      };
    };
  };
}
