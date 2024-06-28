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
    geary.enable = false;
    nm-applet.enable = true;
    sniffnet.enable = true;
    tuxclocker.enable = true;
    virt-manager.enable = true;
    coolercontrol.enable = true;
    system-config-printer.enable = true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################

  environment = {
    systemPackages = with pkgs; [
      hugo
      kitty # keep for sudo / root
      opensnitch-ui # bugreport
    ];
    gnome = {
      excludePackages =
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
    };
    variables = {
      BROWSER = "librewolf";
      TERMINAL = "kitty";
    };
  };

  ###############
  #-=# USERS #=-#
  ###############

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
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          ip-finder.extensionUuid
          media-controls.extensionUuid
          network-interfaces-info.extensionUuid
          network-stats.extensionUuid
          openweather.extensionUuid
          password-calculator.extensionUuid
          runcat.extensionUuid
          todotxt.extensionUuid
        ];
      };
    };
  };

  # maximize-to-workspace-with-history.extensionUuid

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
  #-=# SERVICES #=-#
  ##################

  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false; # disable pulseaudio here (use pipewire)
  };
  sound.enable = false; # disable alsa here (use pipewire)
  security.rtkit.enable = true; # realtime, needed for audio
}
