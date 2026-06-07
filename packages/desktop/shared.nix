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
    acpilight.enable = true;
    i2c.enable = true;
    bluetooth = {
      enable = lib.mkForce false;
      powerOnBoot = lib.mkForce false;
    };
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################

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
    ddccontrol.enable = true;
    speechd.enable = lib.mkForce false;
    actkbd = {
      enable = true;
      bindings = [
        {
          keys = [224];
          events = ["key"];
          command = "/run/current-system/sw/bin/light -A 10";
        }
        {
          keys = [225];
          events = ["key"];
          command = "/run/current-system/sw/bin/light -U 10";
        }
      ];
    };
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
