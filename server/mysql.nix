{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # environment.systemPackages = with pkgs; [];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mysql = {
      enable = true;
    };
    prometheus = {
      exporters = {
        mysql = {
          enable = false;
        };
      };
    };
  };
}
