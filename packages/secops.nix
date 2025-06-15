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
      fangfrisch.enable = true;
      updater.enable = true;
      scanner = {
        enable = true;
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
