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
    ./shared.nix
  ];

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
    };
    hyprlock = {
      enable = true;
    };
    waybar = {
      enable = true;
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    variables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    dbus = {
      enable = true;
    };
    hypridle = {
      enable = true;
    };
  };

  #############
  #-=# XDG #=-#
  #############
  xdg = {
    portal = {
      enable = true;
      wlr = {
        enable = true;
      };
      extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland];
    };
  };
}
