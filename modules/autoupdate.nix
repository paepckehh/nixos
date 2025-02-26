{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs = {
    config = {
      allowBroken = lib.mkDefault true;
      allowUnfree = lib.mkDefault true;
    };
  };

  ###############
  #-= SYSTEM #=-#
  ###############
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      dates = "hourly";
      flake = "github:paepckehh/nixos";
      flags = ["--update-input" "nixpkgs" "--update-input" "home-manager"];
      operation = "boot";
      persistent = true;
      randomizedDelaySec = "15min";
      rebootWindow = {
        lower = "02:00";
        upper = "04:00";
      };
    };
  };
}
