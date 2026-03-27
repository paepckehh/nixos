{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./intel.nix];

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    acpilight.enable = true;
    intel-gpu-tools.enable = true;
    graphics = {
      enable = lib.mkForce true;
      enable32Bit = lib.mkForce true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-vaapi-driver
        vpl-gpu-rt
      ];
    };
  };
}
