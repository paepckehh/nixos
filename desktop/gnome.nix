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
    gnome.excludePackages =
      (with pkgs; [
        gnome-tour
        gnome-calendar
        gnome-terminal
        totem
        geary
        cheese
        gnome-photos
        gnome-tour
        gedit
        evince
        epiphany
      ])
      ++ (with pkgs.gnome; [
        gnome-music
        gnome-contacts
        gnome-characters
        tali
        iagno
        hitori
        atomix
      ]);
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
      gnome-online-miners.enable = lib.mkForce false;
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
