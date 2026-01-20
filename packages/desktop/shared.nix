{
  config,
  pkgs,
  lib,
  ...
}: {
  ###############
  #-=# FONTS #=-#
  ###############
  fonts.packages = [pkgs.nerd-fonts.fira-code];

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    bluetooth = {
      enable = lib.mkDefault true;
      powerOnBoot = lib.mkDefault false;
    };
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    yubikey-manager.enable = true;
    yubikey-touch-detector.enable = true;
  };

  #############
  #-=# XDG #=-#
  #############
  xdg = {
    autostart.enable = lib.mkDefault false;
    mime = {
      enable = true;
      addedAssociations = {"application/pdf" = "org.gnome.Evince.desktop";};
      defaultApplications = {"application/pdf" = "org.gnome.Evince.desktop";};
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    autosuspend.enable = lib.mkForce false;
    speechd.enable = lib.mkForce false;
    xserver = {
      enable = true;
      autoRepeatDelay = 150;
      autoRepeatInterval = 15;
      xkb = {
        layout = "us,de";
        # How to get all installed kbd all options? cd /nix/store && fd base.lst | xargs cat
        # xkbVariant = "workman,";
        # xkbOptions = "grp:win_space_toggle";
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    #  systemPackages = with pkgs; [alacritty];
    systemPackages = with pkgs; [alacritty gparted keepassxc wl-clipboard yubioath-flutter xclip];
    variables.TERMINAL = "alacritty";
  };
}
