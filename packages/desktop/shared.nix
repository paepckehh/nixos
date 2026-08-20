{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    acpilight.enable = true;
    i2c.enable = true;
    bluetooth = {
      enable = lib.mkForce false;
      powerOnBoot = lib.mkForce false;
    };
  };

  ###############
  #-=# FONTS #=-#
  ###############
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [noto-fonts noto-fonts-color-emoji nerd-fonts.fira-code];
    fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        style = "full";
        autohint = true;
      };
      subpixel = {
        rgba = "rgb"; # "rgb", "bgr", "vrgb", "vbgr", "none"
        lcdfilter = "default";
      };
    };
  };

  #############
  #-=# XDG #=-#
  #############
  xdg = {
    autostart.enable = lib.mkDefault false;
    mime = {
      enable = lib.mkForce true;
      addedAssociations = {"application/pdf" = "org.gnome.Papers.desktop";};
      defaultApplications = {"application/pdf" = "org.gnome.Papers.desktop";};
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    autosuspend.enable = lib.mkForce false;
    # ddccontrol.enable = true;
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
    variables.TERMINAL = "alacritty";
    systemPackages = with pkgs; [
      alacritty
      ddcutil
      filezilla
      gparted
      keepassxc
      notepad-next
      wl-clipboard
      yubioath-flutter
      xclip
    ];
  };
}
