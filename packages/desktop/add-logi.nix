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
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd"; # amd, intel
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [logitech-udev-rules logiops solaar]; # keyleds
}
