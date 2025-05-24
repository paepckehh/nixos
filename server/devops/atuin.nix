{config, ...}: {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."10-lan".addresses = [{Addresss = "192.168.80.250/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    atuin = {
      enable = true;
      host = "192.168.80.250";
      port = 8888;
      maxHistoryLength = 65536;
      openFirewall = true;
      openRegistration = true;
    };
  };
}
