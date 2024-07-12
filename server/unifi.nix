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
    };
    prometheus.exporters.unifi.enable = false;
  };
}
