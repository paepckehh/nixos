{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    open-webui = {
      enable = true;
      host = "127.0.0.1";
      port = 6161;
      openFirewall = false;
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

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "ai.pvz.lan" = {
          locations."/".proxyPass = "http://127.0.0.1:6161";
        };
      };
    };
  };
}
