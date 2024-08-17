{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    gitea = {
      enable = true;
      appName = "internal git service";
      settings = {
        server = {
          protocol = "http";
          http_port = 3232;
          http_addr = "127.0.0.1";
        };
      };
    };
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "git.pvz.lan" = {
          locations."/".proxyPass = "http://172.0.0.1:3232";
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
