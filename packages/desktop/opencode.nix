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
    ../opencode.nix
  ];
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
        opencode-desktop
    ];
  };
}
