{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    unifi = {
      enable = true;
      openFirewall = false;
      unifiPackage = pkgs.unifi8;
      mongodbPackage = pkgs.mongodb-6_0;
    };
    prometheus.exporters.unifi = {
      enable = false;
      port = 9130;
    };
  };
}
