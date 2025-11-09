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
    printing.enable = lib.mkForce true;
    hardware.bolt.enable = lib.mkDefault true;
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
      enable = true;
      alsa.enable = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
      wireplumber.enable = lib.mkDefault true;
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = true;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [alacritty gparted keepassxc wl-clipboard yubioath-flutter xclip];
    variables = {
      TERMINAL = "alacritty";
    };
    etc."libinput/local-overrides.quirks".text = ''
      [MacBook(Pro) SPI Touchpads]
      MatchName=*Apple SPI Touchpad*
      ModelAppleTouchpad=1
      AttrTouchSizeRange=200:150
      AttrPalmSizeThreshold=1100

      [MacBook(Pro) SPI Keyboards]
      MatchName=*Apple SPI Keyboard*
      AttrKeyboardIntegration=internal

      [MacBookPro Touchbar]
      MatchBus=usb
      MatchVendor=0x05AC
      MatchProduct=0x8600
      AttrKeyboardIntegration=internal
    '';
  };
}
