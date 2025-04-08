{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services.blueman.enable = true;
}
