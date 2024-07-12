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
      openfirewall = false;
      unifiPackage = pkgs.unifi8;
    };
    prometheus.exporters.unifi.enable = false;
  };
}
