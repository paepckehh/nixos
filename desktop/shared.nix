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


  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs = {
    config.packageOverrides = pkgs: with pkgs; {
     firefox = stdenv.lib.overrideDerivation librefox (_: {
      desktopItem = makeDesktopItem {...};
     });
   };
 };

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
    systemPackages = with pkgs; [alacritty kitty];
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
    blueman.enable = lib.mkForce true;
    speechd.enable = lib.mkForce false;
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
      pulse.enable = true;
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    # graphics.extraPackages = with pkgs; [intel-vaapi-driver intel-ocl intel-media-driver];
    graphics.enable = true;
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
