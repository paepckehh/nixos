{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    plikd = {
      enable = true;
      openFireWall = true;
      settings = {};
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
