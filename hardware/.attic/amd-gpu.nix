{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    amdgpu = {
      amdvlk = {
        enable = true;
        support32Bit.enable = true;
      };
      opencl.enable = true;
    };
  };
}
