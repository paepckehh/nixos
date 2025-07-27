{
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./netops.nix
  ];

  #################
  #-=# IMPORTS #=-#
  #################
  services = {
    clamav = {
      fangfrisch.enable = false;
      updater.enable = false;
      scanner = {
        enable = false;
        interval = lib.mkForce "";
        scanDirectories = lib.mkForce [];
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      clamav
      yara
      yara-x
      yaralyzer
    ];
  };
}
