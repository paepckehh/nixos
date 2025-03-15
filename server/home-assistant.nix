{
  config,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    home-assistant = {
      enable = true;
    };
  };
}
