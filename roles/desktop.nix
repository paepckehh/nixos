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
      ])
      ++ (with pkgs.gnome; [
        cheese
        gnome-music
        gnome-contacts
        gnome-terminal
        gnome-characters
        epiphany
        geary
        evince
        totem
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
          }; # emulate kitty
          colors.primary = {
            background = "#000000";
            foreground = "#767676";
          };
          colors.normal = {
            black = "#cc0403";
            red = "#19cb00";
            green = "#cecb00";
            yellow = "#0d73cc";
            blue = "#cb1ed1";
            magenta = "#0dcdcd";
            cyan = "#dddddd";
            white = "#ffffff";
          };
          colors.bright = {
            black = "#f2201f";
            red = "#23fd00";
            green = "#fffd00";
            yellow = "#1a8fff";
            blue = "#fd28ff";
            magenta = "#14ffff";
            cyan = "#ffffff";
            white = "#ffffff";
          };
        };
      };
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = true;
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
        gnome.enable = true;
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
