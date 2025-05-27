{
  config,
  pkgs,
  lib,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # add generic terminal pkg for all, configure individually via home-manager profile
  environment = {
    systemPackages = with pkgs; [alacritty gparted keepassxc wl-clipboard];
    variables = {
      TERMINAL = "alacritty";
    };
  };

  ###############
  #-=# FONTS #=-#
  ###############
  fonts.packages = ( # no support for pre24.11
    if (config.system.nixos.release == "24.11")
    then [(pkgs.nerdfonts.override {fonts = ["FiraCode"];})]
    else [pkgs.nerd-fonts.fira-code]
  );

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
      alsa.enable = lib.mkDefault false;
      pulse.enable = lib.mkDefault false;
      wireplumber.enable = lib.mkDefault false;
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = true;
}
