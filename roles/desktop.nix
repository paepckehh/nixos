{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    dconf.enable = true;
    geary.enable = false;
    nm-applet.enable = true;
    tuxclocker.enable = true;
    coolercontrol.enable = true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # maximize-to-workspace-with-history
  environment = {
    systemPackages =
      (with pkgs; [
        kitty
        opensnitch-ui
      ])
      ++ (with pkgs.gnomeExtensions; [
        drive-menu
        todotxt
      ]);
    gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
        gedit
      ])
      ++ (with pkgs.gnome; [
        cheese
        gnome-music
        gnome-terminal
        epiphany
        geary
        evince
        gnome-characters
        totem
        tali
        iagno
        hitori
        atomix
      ]);
    variables = {
      BROWSER = "librewolf";
      TERMINAL = "kitty";
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    programs = {
      go = {
        enable = true;
      };
      kitty = {
        enable = true;
      };
      librewolf = {
        enable = true;
      };
    };
    services = {
      blanket = {
        enable = true;
      };
      opensnitch-ui = {
        enable = true;
      };
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            drive-menu.extensionUuid
            todotxt.extensionUuid
          ];
        };
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
        };
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    avahi.enable = lib.mkForce false;
    gnome.evolution-data-server.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager = {
        gnome.enable = true;
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
