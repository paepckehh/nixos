{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    plikd = {
      enable = true;
      openFirewall = true;
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
