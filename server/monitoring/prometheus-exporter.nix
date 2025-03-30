{
  config,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      exporters = {
        # chrony.enable = true;
        ecoflow.enable = true;
        tibber = {
          enable = true;
          apiTokenFile =
            ./keys/tibber.txt;
        };
      };
    };
  };
}
