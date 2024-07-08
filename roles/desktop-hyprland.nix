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
    programs.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
        hidpi = true;
      };
    };
    firejail = {
      enable = true;
      wrappedBinaries = {
        librewolf = {
          profile = "${lib.getBin pkgs.firejail}/etc/firejail/librewolf.profile";
          executable = "${lib.getBin pkgs.librewolf}/bin/librewolf";
        };
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [alacritty gparted librewolf];
    variables = {
      BROWSER = "librewolf";
      TERMINAL = "alacritty";
      NIXOS_OZONE_WL = "1";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    autosuspend.enable = lib.mkForce false;
    dbus.enable = true;
    printing.enable = lib.mkForce false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      autoRepeatDelay = 150;
      autoRepeatInterval = 15;
      desktopManager = {
        xterm.enable = false;
      };
    };
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
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
