{
  config,
  pkgs,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot.extraModulePackages = [
    config.boot.kernelPackages.zenpower
  ];

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware.cpu.amd = {
    updateMicrocode = lib.mkForce true;
    ryzen-smu.enable = lib.mkForce true;
    sev.enable = lib.mkForce true;
  };
}
