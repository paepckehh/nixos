{
  config,
  pkgs,
  lib,
  ...
}: {
  ###############
  #-=# FONTS #=-#
  ###############
  # fonts = {
  #  packages = with pkgs; [nerd-fonts.fira-code];
  #  packages = with pkgs; [(nerdfonts.override {fonts = ["FiraCode"];})];
  # };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
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
    blueman.enable = true;
    speechd.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
    xserver = {
      enable = true;
      autoRepeatDelay = 150;
      autoRepeatInterval = 15;
      xkb.layout = "us,de";
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = true;
}
