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
    firejail = {
      enable = true;
      wrappedBinaries = {
        librewolf = {
          profile = "${lib.getBin pkgs.firejail}/etc/firejail/librewolf.profile";
          executable = "${lib.getBin pkgs.librewolf}/bin/librewolf";
          desktop = "${lib.getBin pkgs.librewolf}/share/applications/librewolf.desktop";
        };
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [alacritty pulseaudio kitty];
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
    blueman.enable = lib.mkForce false;
    speechd.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
    xserver = {
      enable = true;
      autoRepeatDelay = 150;
      autoRepeatInterval = 15;
      xkb.layout = "us,de";
    };
    pipewire = {
      enable = false;
      pulse.enable = false;
      wireplumber.enable = false;
      alsa = {
        enable = false;
        support32Bit = true;
      };
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    # graphics.extraPackages = with pkgs; [intel-vaapi-driver intel-ocl intel-media-driver];
    graphics.enable = true;
    pulseaudio.enable = false;
    bluetooth = {
      enable = false;
      powerOnBoot = false;
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = false; # realtime, only needed for audio
}
