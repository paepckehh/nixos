{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    gitea = {
      enable = true;
      appName = "PVZ Internal git service";
      settings = {
        server = {
          protocol = "http";
          http_port = 3030;
          http_addr = "127.0.0.1";
        };
      };
    };
    prometheus.exporters.nginx = {
      enable = false;
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}
