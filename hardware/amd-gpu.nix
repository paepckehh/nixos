{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./amd.nix
  ];

  ##############
  #-=# BOOT #=-#
  ##############
  boot.kernelModules = [
    "amdgpu"
  ];

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    amdgpu.opencl.enable = true;
    firmware = [pkgs.linux-firmware];
  };
}
