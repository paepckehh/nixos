{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../desktop/add-bluetooth.nix
    ../desktop/add-sound.nix
  ];

  ##############
  #-=# BOOT #=-#
  ##############
  boot.blacklistedKernelModules = ["dvb_usb_rtl28xxu"];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [welle-io];
}
