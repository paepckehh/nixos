{
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../me.nix
    ./firefox.nix
  ];

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_USE_XINPUT2 = "1";
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            toggle-alacritty.extensionUuid
          ];
          favorite-apps = ["Alacritty.desktop" "firefox.desktop" "librewolf.desktop" "org.keepassxc.KeePassXC.desktop"];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "alacritty terminal";
          command = "alacritty";
          binding = "<Super>Return";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          name = "firefox browser not-sandboxed";
          command = "firefox";
          binding = "<Super>b";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          name = "firefox browser not-sandboxed";
          command = "firefox";
          binding = "<Super>f";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          name = "librefox browser within firejail";
          command = "librewolf-firejail";
          binding = "<Super>w";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
          name = "keepassxc passwordmanager";
          command = "keepassxc";
          binding = "<Super>k";
        };
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
        };
      };
    };
    programs = {
      alacritty = {
        enable = true;
        settings = {
          selection = {
            save_to_clipboard = true;
          };
          scrolling = {
            history = 100000;
          };
          font.size = 13;
          colors = {
            primary = {
              background = "#000000";
              foreground = "#fffbf6";
            };
            normal = {
              black = "#000000";
              red = "#eb4129";
              green = "#abe047";
              yellow = "#f6c744";
              blue = "#47a0f3";
              magenta = "#7b5cb0";
              cyan = "#64dbed";
              white = "#e5e9f0";
            };
            bright = {
              black = "#565656";
              red = "#ec5357";
              green = "#c0e17d";
              yellow = "#f9da6a";
              blue = "#49a4f8";
              magenta = "#a47de9";
              cyan = "#99faf2";
              white = "#ffffff";
            };
            draw_bold_text_with_bright_colors = true;
          };
          window = {
            decorations = "none";
            startup_mode = "Fullscreen";
          };
        };
      };
      keepassxc = {
        enable = true;
        settings = {
          Browser.Enabled = true;
          SSHAgent.Enabled = false;
          GUI = {
            AdvancedSettings = true;
            ApplicationTheme = "dark";
            CompactMode = true;
            HidePasswords = true;
          };
        };
      };
    };
    services = {
      remmina.enable = false;
      network-manager-applet.enable = true;
    };
  };
}
