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
    ./intel.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # intel gpu audio
  environment.systemPackages = with pkgs; [
    sof-firmware
  ];

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
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
