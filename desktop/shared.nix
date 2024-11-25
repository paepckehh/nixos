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
      enable = false; # TODO: performance impact
      enable32Bit = false;
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

  ##################
  #-=# PROGRAMS #=-#
  ##################
  # programs = {
  #  firejail = {
  #   enable = true;
  #    wrappedBinaries = {
  #      librewolf = {
  #        profile = "${lib.getBin pkgs.firejail}/etc/firejail/librewolf.profile";
  #        executable = "${lib.getBin pkgs.librewolf}/bin/librewolf";
  #        desktop = "${lib.getBin pkgs.librewolf}/share/applications/librewolf.desktop";
  #      };
  #    };
  #  };
  #};
}
