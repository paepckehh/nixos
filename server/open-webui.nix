{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    open-webui = {
      enable = false;
      host = "127.0.0.1";
      port = 8080;
      openFirewall = false;
    };
  };
}
