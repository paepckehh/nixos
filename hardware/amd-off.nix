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
    blacklistedKernelModules = [];
    extraModprobeConfig = '''';
    initrd = {
      availableKernelModules = [
      ];
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
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
    udev.extraRules = '''';
  };
}
