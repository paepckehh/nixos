{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    open-webui = {
      enable = true;
      host = "127.0.0.1";
      port = 8080;
      openFirewall = false;
    };
  };
}
