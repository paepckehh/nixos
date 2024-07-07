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
    ../modules/open-webui.nix
  ];

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    dconf.enable = true;
    geary.enable = false;
    nm-applet.enable = true;
    tuxclocker.enable = true;
    coolercontrol.enable = true;
    firejail = {
      enable = true;
      wrappedBinaries = {
        librewolf = {
          executable = "${pkgs.librewolf}/bin/librewolf";
          profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
        };
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # maximize-to-workspace-with-history
  environment = {
    systemPackages =
      (with pkgs; [
        alacritty
        gparted
        kitty
        librewolf
        opensnitch-ui
      ])
      ++ (with pkgs.gnomeExtensions; [
        todotxt
        toggle-alacritty
        wireguard-vpn-extension
        wireless-hid
        wifi-qrcode
      ]);
    gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
        gedit
        gnome-terminal
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
    variables = {
      BROWSER = "librewolf";
      TERMINAL = "alacritty";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    autosuspend.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
    gnome = {
      games.enable = lib.mkForce false;
      gnome-browser-connector.enable = lib.mkForce false;
      gnome-initial-setup.enable = lib.mkForce false;
      gnome-online-accounts.enable = lib.mkForce false;
      gnome-remote-desktop.enable = lib.mkForce false;
      gnome-online-miners.enable = lib.mkForce false;
      gnome-user-share.enable = lib.mkForce false;
    };
    xserver = {
      enable = true;
      autoRepeatDelay = 150;
      autoRepeatInterval = 15;
      displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
      desktopManager = {
        gnome = {
          enable = true;
        };
        xterm.enable = false;
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false; # disable pulseaudio here (use pipewire)
  };
  sound.enable = false; # disable alsa here (use pipewire)
  security.rtkit.enable = true; # realtime, needed for audio
}
