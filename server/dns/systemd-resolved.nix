{pkgs, ...}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    nameservers = ["192.168.8.1" ];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    resolved = {
      enable = true;
      fallbackDns = "192.168.8.1";
    };
}
