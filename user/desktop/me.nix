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
    ../me.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [nvtopPackages.full gparted networkmanagerapplet opensnitch-ui];
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    coolercontrol.enable = true;
    tuxclocker.enable = true;
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    services = {
      remmina.enable = true;
    };
    programs = {
      librewolf.enable = true;
      kitty = {
        enable = true;
        settings = {
          font_size = 10;
          hide_window_decorations = false;
        };
      };
      alacritty = {
        enable = true;
        settings = {
          selection = {
            save_to_clipboard = true;
          };
          scrolling = {
            history = 100000;
          };
          mouse = {
            hide_when_typing = true;
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
          window = {
            decorations = "none";
            startup_mode = "Fullscreen";
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
          favorite-apps = ["Alacritty.desktop" "kitty.desktop" "librewolf.desktop"];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "alacritty terminal";
          command = "alacritty";
          binding = "<Super>Return";
        };
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
        };
      };
    };
  };
}
