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
    # nixos => 25.05
    packages = with pkgs; [nerd-fonts.fira-code];
    # nixos <= 24.11:
    # packages = with pkgs; [(nerdfonts.override {fonts = ["FiraCode"];})];
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # add generic terminal pkg for all, configure individually via home-manager profile
  environment = {
    systemPackages = with pkgs; [alacritty];
    variables = {
      TERMINAL = "alacritty";
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware.bluetooth.enable = false;

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    autosuspend.enable = lib.mkForce false;
    speechd.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
    xserver = {
      enable = true;
      autoRepeatDelay = 150;
      autoRepeatInterval = 15;
      # How to get all installed kbd all options?
      # cd /nix/store && fd base.lst | xargs cat
      xkb = {
        layout = "us,de";
        # xkbVariant = "workman,";
        # xkbOptions = "grp:win_space_toggle";
      };
    };
    pipewire = {
      enable = false;
      pulse.enable = false;
      wireplumber.enable = false;
      alsa.enable = false;
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = true;
}
