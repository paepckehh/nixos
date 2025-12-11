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
      contact
      linuxPackages.usbip
      ungoogled-chromium
    ];
  };
}
