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
      hugo # prep PR
      kitty # keep for sudo / root
      opensnitch-ui # bugreport
    ];
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
      opensnitch-ui.enable = true;
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################

  services = {
    avahi.enable = lib.mkForce false;
    gnome.evolution-data-server.enable = lib.mkForce false;
    printing = {
      enable = true;
      stateless = true;
      clientConf = ''
        # ServerName cups.intra
      '';
      startWhenNeeded = true;
      cups-pdf = {
        enable = true;
      };
    };
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
