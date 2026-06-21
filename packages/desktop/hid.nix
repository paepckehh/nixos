{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    keyboard.qmk.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = lib.mkForce true;
    };
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    udev.packages = with pkgs; [via];
    hardware.openrgb = {
      enable = true;
      motherboard = "amd"; # amd, intel
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [logitech-udev-rules logiops solaar via keyleds];
}
