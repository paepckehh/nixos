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
    systemPackages = with pkgs; [pkgs.distrobox];
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };
}
