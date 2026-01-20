{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../me.nix
    ./browser/me.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
  ];

  ################
  #-=# SYSTEN #=-#
  ################
  system.activationScripts.script.text = ''
    cp -f /home/me/.face /var/lib/AccountsService/icons/me
  '';

  ##################
  #-=# SECURITY #=-#
  ##################
  security.pam.services.me.enableGnomeKeyring = true;

  ##################
  #-=# SECURITY #=-#
  ##################
  services.displayManager.autoLogin = {
    enable = true;
    user = "me";
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    home = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_USE_XINPUT2 = "1";
      };
      packages = with pkgs; [
        gnomeExtensions.dash-to-panel
        gnomeExtensions.clipboard-indicator
      ];
      file.".face".source = ../../shared/brand/me.jpg;
    };
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
            clipboard-indicator.extensionUuid
          ];
          favorite-apps = [
            "Alacritty.desktop"
            "com.mitchellh.ghostty.desktop"
            "kitty.desktop"
            "dss.desktop"
            "firefox.desktop"
            "librewolf.desktop"
            "org.keepassxc.KeePassXC.desktop"
            "org.gnome.Nautilus.desktop"
            "bitwarden.desktop"
            "element-desktop.desktop"
            "thunderbird.desktop"
            "onlyoffice-desktopeditors.desktop"
            "com.yubico.yubioath.desktop"
          ];
        };
        "org.gnome.desktop.notifications" = {
          application-children = [];
          show-banners = false;
          show-in-lock-screen = false;
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
          name = "[f]ile browser - nautilus";
          command = "nautilus";
          binding = "<Super>f";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          name = "[b]rowser = librewolf, not-sandboxed";
          command = "librewolf";
          binding = "<Super>b";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          name = "[p]asswordmanager";
          command = "vaultwarden";
          binding = "<Super>p";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
          name = "[k]eepassxc passwordmanager";
          command = "keepassxc";
          binding = "<Super>k";
        };
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
        };
        "org.gnome.desktop.wm.preferences" = {
          button-layout = "minimize,maximize,close";
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
        enable = false;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        installBatSyntax = true;
        installVimSyntax = true;
        settings = {
          theme = "Synthwave";
          font-size = 11;
        };
      };
      kitty = {
        enable = false;
        enableGitIntegration = true;
        shellIntegration = {
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
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
          font.size = 11;
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
    };
  };
}
