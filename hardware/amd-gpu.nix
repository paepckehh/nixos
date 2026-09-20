{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./amd.nix];

  ##############
  #-=# BOOT #=-#
  ##############
  boot.kernelModules = ["amdgpu"];

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    acpilight.enable = true;
    amdgpu.opencl.enable = true;
    firmware = [pkgs.linux-firmware];
  };
}
