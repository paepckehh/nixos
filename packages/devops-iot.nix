{
  config,
  pkgs,
  lib,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      # mqtt-explorer
      rpi-imager
      linuxPackages.usbip
    ];
  };
}
