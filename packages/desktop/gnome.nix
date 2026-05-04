{
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
    geary.enable = lib.mkForce false;
    seahorse.enable = true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      gnome-decoder
      gnome-firmware
    ];
    gnome.excludePackages = with pkgs; [
      gnome-calendar
      gnome-contacts
      gnome-photos
      gnome-tour
      gnome-music
      atomix
      cheese
      geary
      epiphany
      showtime
      iagno
      totem
      hitori
      tali
      tinysparql
    ];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    gvfs.enable = true;
    speechd.enable = lib.mkForce false;
    orca.enable = lib.mkForce false;
    gnome = {
      core-os-services.enable = true;
      core-shell.enable = true;
      core-apps.enable = lib.mkForce true;
      core-developer-tools.enable = lib.mkForce false;
      evolution-data-server.enable = lib.mkForce false;
      games.enable = lib.mkForce false;
      gnome-browser-connector.enable = lib.mkForce false;
      gnome-initial-setup.enable = lib.mkForce false;
      gnome-online-accounts.enable = lib.mkForce false;
      gnome-keyring.enable = true;
      gnome-remote-desktop.enable = lib.mkForce false;
      gnome-user-share.enable = lib.mkForce false;
      sushi.enable = lib.mkForce false;
      localsearch.enable = lib.mkForce false;
      tinysparql.enable = lib.mkForce false;
      rygel.enable = lib.mkForce false;
    };
    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      autoSuspend = false;
      banner = ''hardened nixos gnome desktop '';
      wayland = true;
    };
  };
}
