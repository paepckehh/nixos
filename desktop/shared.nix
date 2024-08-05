{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [];

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    coolercontrol.enable = true;
    tuxclocker.enable = true;
    nm-applet.enable = true;
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
    systemPackages = with pkgs; [alacritty element-desktop gparted networkmanagerapplet opensnitch-ui];
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
    blueman.enable = true;
    printing.enable = lib.mkForce true;
    xserver = {
      enable = true;
      autoRepeatDelay = 150;
      autoRepeatInterval = 15;
      xkb.layout = "us,de";
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      # pulse.enable = true;
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    # graphics.extraPackages = with pkgs; [intel-vaapi-driver intel-media-driver];
    pulseaudio.enable = false; # disable pulseaudio here (use pipewire)
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = true; # realtime, needed for audio
}
