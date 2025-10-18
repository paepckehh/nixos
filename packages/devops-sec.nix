{
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./devops-net.nix
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
