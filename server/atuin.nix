{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    atuin = {
      enable = true;
      host = "127.0.0.1";
      port = 8888;
      maxHistroyLength = 32768;
      openFirewall = true;
      openRegistration = true;
    };
  };
}
