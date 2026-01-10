{
  config,
  lib,
  modulesPath,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [];

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    xserver.videoDrivers = ["nvidia"];
  };
}
