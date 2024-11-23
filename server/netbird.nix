{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    netbird = {
      enable = true;
      server = {
        signal = {
          enable = true;
        };
        management = {
          enable = true;
        };
        dashboard = {
          enable = false;
          managementServer = "localhost";
        };
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [];
    };
  };
}
