{
  config,
  pkgs,
  lib,
  ...
}: {
  ###############
  #-=# FONTS #=-#
  ###############
  fonts = {
    packages = with pkgs; [(nerdfonts.override {fonts = ["FiraCode"];})];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    graphics = {
      enable = lib.mkForce true;
      enable32Bit = lib.mkForce true;
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [alacritty];
    variables = {
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
        support32Bit = false;
      };
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = false; # realtime, only needed for audio

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    bluetooth = {
      enable = false;
      powerOnBoot = false;
    };
  };
}
