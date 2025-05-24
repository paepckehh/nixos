{config, ...}: {
  #################
  #-=# SYSTEMD #=-#
  #################
  # ensure dns server record 192.168.80.251 -> atuin.lan
  systemd.network.networks."10-lan".addresses = [{Address = "192.168.80.251/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    atuin = {
      enable = true;
      host = "192.168.80.251";
      port = 8888;
      maxHistoryLength = 65536;
      openFirewall = true;
      openRegistration = true;
    };
  };
}
