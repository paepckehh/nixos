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
    (modulesPath + "/hardware/network/broadcom-43xx.nix")
  ];

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = [
        "applespi"
        "applesmc"
        "spi_pxa2xx_platform"
        "intel_lpss_pci"
      ];
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    wireless.enable = true;
    enableB43Firmware = true;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mbpfan.enable = true;
  };
}
