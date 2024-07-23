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
    geary.enable = false;
    dconf = {
      enable = true;
      profiles.gdm.databases = [{settings."org/gnome/settings-daemon/plugins/power" = {power-button-action = "suspend";};}];
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs.gnomeExtensions; [todotxt toggle-alacritty wireguard-vpn-extension wireless-hid wifi-qrcode];
    gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
        gedit
        gnome-calendar
        totem
        evince
        epiphany
        geary
        cheese
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

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    services = {
      geoclue = {
        enable = false;
        restartIfChanged = false;
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    gnome = {
      core-utilities.enable = lib.mkForce false;
      games.enable = lib.mkForce false;
      gnome-browser-connector.enable = lib.mkForce false;
      gnome-initial-setup.enable = lib.mkForce false;
      gnome-online-accounts.enable = lib.mkForce false;
      gnome-remote-desktop.enable = lib.mkForce false;
      gnome-online-miners.enable = lib.mkForce false;
      gnome-user-share.enable = lib.mkForce false;
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
