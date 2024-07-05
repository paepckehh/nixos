{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../modules/open-webui.nix
  ];

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    dconf.enable = true;
    geary.enable = false;
    nm-applet.enable = true;
    tuxclocker.enable = true;
    coolercontrol.enable = true;
    firejail = {
      enable = true;
      wrappedBinaries = {
        librewolf = {
          executable = "${pkgs.librewolf}/bin/librewolf";
          profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
        };
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # maximize-to-workspace-with-history
  environment = {
    systemPackages =
      (with pkgs; [
        alacritty
        gparted
        kitty
        librewolf
        opensnitch-ui
      ])
      ++ (with pkgs.gnomeExtensions; [
        todotxt
        toggle-alacritty
        wireguard-vpn-extension
        wireless-hid
        wifi-qrcode
      ]);
    gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
        gedit
        gnome-terminal
        gnome-calendar
        totem
        evince
        epiphany
        geary
        cheese
      ])
      ++ (with pkgs.gnome; [
        gnome-music
        gnome-contacts
        gnome-characters
        tali
        iagno
        hitori
        atomix
      ]);
    variables = {
      BROWSER = "librewolf";
      TERMINAL = "alacritty";
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    programs = {
      kitty = {
        enable = true;
        settings = {
          font_size = 10;
          hide_window_decorations = true;
        };
      };
      alacritty = {
        enable = true;
        settings = {
          window = {
            decorations = "none";
            startup_mode = "Fullscreen";
          };
          selection = {
            save_to_clipboard = true;
          };
          font.size = 10;
          colors.primary = {
            background = "#000000";
            foreground = "#fffbf6";
          };
          colors.normal = {
            black = "#2e2e2e";
            red = "#eb4129";
            green = "#abe047";
            yellow = "#f6c744";
            blue = "#47a0f3";
            magenta = "#7b5cb0";
            cyan = "#64dbed";
            white = "#e5e9f0";
          };
          colors.bright = {
            black = "#565656";
            red = "#ec5357";
            green = "#c0e17d";
            yellow = "#f9da6a";
            blue = "#49a4f8";
            magenta = "#a47de9";
            cyan = "#99faf2";
            white = "#ffffff";
          };
        };
      };
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            todotxt.extensionUuid
            toggle-alacritty.extensionUuid
            wireguard-vpn-extension.extensionUuid
            wireless-hid.extensionUuid
            wifi-qrcode.extensionUuid
          ];
        };
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
        };
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    printing.enable = lib.mkForce false;
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager = {
        gnome = {
          enable = true;
          favoriteAppsOverride = ''
            [org.gnome.shell]
            favorite-apps=[ 'alacritty.desktop', 'kitty.desktop', 'librewolf.desktop', 'opensnitch.desktop' ]'';
        };
        xterm.enable = false;
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = false; # disable pulseaudio here (use pipewire)
  };
  sound.enable = false; # disable alsa here (use pipewire)
  security.rtkit.enable = true; # realtime, needed for audio
}
