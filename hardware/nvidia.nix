{
  config,
  lib,
  modulesPath,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
  ];

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = [
      ];
    };
  };

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

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    xserver.videoDrivers = ["nvidia"];
  };
}
