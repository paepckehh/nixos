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
  ];

  ##################
  #-=# SECURITY #=-#
  ##################
  security.pam.services.me.enableGnomeKeyring = true;

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
    xdg = {
      autostart = {
        enable = true;
        readOnly = true;
        entries = [
          # "${pkgs.element-desktop}/share/applications/element-desktop.desktop"
        ];
      };
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            dash-to-panel.extensionUuid
          ];
          favorite-apps = ["Alacritty.desktop" "com.mitchellh.ghostty.desktop" "dss.desktop" "firefox.desktop" "librewolf.desktop" "org.keepassxc.KeePassXC.desktop" "org.gnome.Nautilus.desktop" "element-desktop.desktop" "onlyoffice-desktopeditors.desktop"];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "alacritty terminal";
          command = "alacritty";
          binding = "<Super>Return";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          name = "ghostty terminal";
          command = "ghostty";
          binding = "<Super>\\";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          name = "[f]ile browser - nautilus";
          command = "nautilus";
          binding = "<Super>f";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          name = "[b]rowser = librewolf, not-sandboxed";
          command = "librewolf";
          binding = "<Super>b";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
          name = "[p]asswordmanager";
          command = "vaultwarden";
          binding = "<Super>p";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
          name = "[k]eepassxc passwordmanager";
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
      ghostty = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        installBatSyntax = true;
        installVimSyntax = true;
        settings = {
          theme = "adm";
          font-size = 13;
        };
        themes = {
          adm = {
            background = "000000";
            foreground = "fffbf6";
            cursor-color = "f5e0dc";
            palette = [
              "0=#45475a"
              "1=#f38ba8"
              "2=#a6e3a1"
              "3=#f9e2af"
              "4=#89b4fa"
              "5=#f5c2e7"
              "6=#94e2d5"
              "7=#bac2de"
              "8=#585b70"
              "9=#f38ba8"
              "10=#a6e3a1"
              "11=#f9e2af"
              "12=#89b4fa"
              "13=#f5c2e7"
              "14=#94e2d5"
              "15=#a6adc8"
            ];
            selection-background = "353749";
            selection-foreground = "cdd6f4";
          };
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
      element-desktop = {
        enable = false;
        settings.default_country_code = "de";
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
