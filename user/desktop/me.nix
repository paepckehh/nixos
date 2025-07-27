{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../me.nix
    ./ff.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    gnomeExtensions.network-stats
  ];

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_USE_XINPUT2 = "1";
    };
    home.packages = with pkgs; [
      gnomeExtensions.dash-to-panel
    ];
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            dash-to-panel.extensionUuid
          ];
          favorite-apps = ["Alacritty.desktop" "dss.desktop" "firefox.desktop" "librewolf.desktop" "org.keepassxc.KeePassXC.desktop" "org.gnome.Nautilus.desktop"];
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
          name = "default [f]ile browser - nautilus";
          command = "nautilus";
          binding = "<Super>f";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          name = "default [b]rowser = librewolf, not-sandboxed";
          command = "firefox";
          binding = "<Super>b";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          name = "[w]olf = librewolf firejail";
          command = "jailwolf";
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
        # "org/gnome/desktop/background" = {
        #   picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-l.png";
        #   picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
        # };
        # "org/gnome/desktop/screensaver" = {
        #   picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
        #   primary-color = "#3465a4";
        #  secondary-color = "#000000";
        # };
      };
    };
    programs = {
      tmux.enable = true;
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
      zellij = {
        enable = true;
        enableBashIntegration = false;
        enableFishIntegration = false;
        enableZshIntegration = false;
      };
    };
    services = {
      remmina.enable = false;
      network-manager-applet.enable = true;
    };
  };
}
