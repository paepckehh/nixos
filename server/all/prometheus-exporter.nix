{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      exporters = {
        tibber = {
          enable = true;
        };
      };
    };
  };
}
