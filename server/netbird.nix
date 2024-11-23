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
          enable = true;
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
