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
          enable = false;
          oidcConfigEndpoint = "localhost";
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
