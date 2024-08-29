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
    geary.enable = lib.mkForce false;
    seahorse.enable = lib.mkForce false;
    dconf = {
      enable = true;
      profiles.gdm.databases = [{settings."org/gnome/settings-daemon/plugins/power" = {power-button-action = "suspend";};}];
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs.gnomeExtensions; [toggle-alacritty wireguard-vpn-extension wifi-qrcode];
    gnome.excludePackages = with pkgs; [
      gnome-characters
      gnome-calendar
      gnome-contacts
      gnome-photos
      gnome-tour
      gnome-terminal
      gnome-music
      atomix
      cheese
      geary
      epiphany
      iagno
      totem
      gedit
      evince
      hitori
      tali
    ];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    gvfs.enable = lib.mkForce false;
    gnome = {
      core-utilities.enable = lib.mkForce false;
      games.enable = lib.mkForce false;
      gnome-browser-connector.enable = lib.mkForce false;
      gnome-initial-setup.enable = lib.mkForce false;
      gnome-online-accounts.enable = lib.mkForce false;
      gnome-remote-desktop.enable = lib.mkForce false;
      gnome-user-share.enable = lib.mkForce false;
      gnome-keyring.enable = lib.mkForce false;
    };
    xserver = {
      displayManager.gdm = {
        enable = true;
        autoSuspend = false;
        banner = ''hardened nixos gnome desktop '';
      };
      desktopManager = {
        gnome = {
          enable = true;
        };
      };
    };
  };
}
