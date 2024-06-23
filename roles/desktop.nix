{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# PROGRAMS #=-#
  ##################

  programs = {
    geary.enable = false;
    nm-applet.enable = true;
    sniffnet.enable = true;
    tuxclocker.enable = true;
    virt-manager.enable = true;
    coolercontrol.enable = true;
    system-config-printer.enable = true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################

  environment = {
    systemPackages = with pkgs; [
      go
      kitty
      librewolf
      opensnitch-ui
      vimPlugins.vim-go
    ];
  };

  ###############
  #-=# USERS #=-#
  ###############

  home-manager.users.me = {
    services = {
      opensnitch-ui.enable = true;
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################

  services = {
    avahi.enable = lib.mkForce false;
    gnome.evolution-data-server.enable = lib.mkForce false;
    printing = {
      enable = true;
      stateless = true;
      clientConf = ''
        # ServerName cups.intra
      '';
      startWhenNeeded = true;
      cups-pdf = {
        enable = true;
      };
    };
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager = {
        gnome.enable = true;
        xterm.enable = false;
      };
    };
    pipewire = {
      enable = lib.mkEnforce false;
      alsa.enable = false;
      alsa.support32Bit = true;
      pulse.enable = false;
    };
  };
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = true; # allow pipewire
}
