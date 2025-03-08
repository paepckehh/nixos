{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    open-webui = {
      enable = true;
      host = "127.0.0.1";
      port = 6161;
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  # networking.firewall.allowedTCPPorts = [80 443];
}
