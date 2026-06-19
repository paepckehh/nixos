{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
  bookmarks.ManagedBookmarks = lib.importJSON ../../shared/bookmarks.json;
in {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../me.nix
    ./me-element.nix
    ./me-firefox.nix
    # ./me-librewolf.nix
    ./me-thunderbird.nix
    ../../client/addHomeFix.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [adwaita-icon-theme rustdesk-flutter];

  ##################
  #-=# SECURITY #=-#
  ##################
  security.pam.services.me.enableGnomeKeyring = lib.mkForce false;

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.home-fix-me = {
    description = "fix home directory user me, run once at boot";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "root";
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/home-fix.sh me";
      RemainAfterExit = true;
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    home = {
      file.".face".source = ../../shared/brand/me.jpg;
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_USE_XINPUT2 = "1";
      };
      packages = with pkgs; [
        gnomeExtensions.brightness-control-using-ddcutil
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.dash-to-panel
        gnomeExtensions.vitals
      ];
    };
    xdg = {
      autostart = {
        enable = true;
        readOnly = true;
        entries = []; # example: "${pkgs.element-desktop}/share/applications/element-desktop.desktop"
      };
      mime.enable = true;
      mimeApps = {
        enable = true;
        associations.added = {
          "application/pdf" = "org.gnome.Papers.desktop";
        };
        defaultApplications = {
          "application/pdf" = "org.gnome.Papers.desktop";
        };
      };
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            brightness-control-using-ddcutil.extensionUuid
            clipboard-indicator.extensionUuid
            dash-to-panel.extensionUuid
            vitals.extensionUuid
          ];
          favorite-apps = [
            "com.mitchellh.ghostty.desktop"
            "kitty.desktop"
            "dss.desktop"
            "firefox.desktop"
            "org.keepassxc.KeePassXC.desktop"
            "org.gnome.Nautilus.desktop"
            "onlyoffice-desktopeditors.desktop"
            "com.yubico.yubioath.desktop"
            "org.remmina.Remmina.desktop"
            "Alacritty.desktop"
          ];
        };
        "org/gnome.desktop/notifications" = {
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
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "ghostty terminal";
          command = "ghostty";
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
      };
    };
    programs = {
      onlyoffice = {
        enable = true;
        settings = {
          editorWindowMode = "false";
          locale = infra.locale.lang;
          maximized = true;
          titlebar = "Start";
        };
      };
      ghostty = {
        enable = true;
        installBatSyntax = true;
        installVimSyntax = true;
        systemd.enable = true;
        settings = {
          theme = "clean"; # Argonout
          cursor-style = "block";
          cursor-style-blink = "false";
          background = "#000000";
          fullscreen = "true";
          font-size = "11";
          notify-on-command-finish-action = "bell,notify";
          notify-on-command-finish-after = "30s";
          shell-integration = "fish";
          shell-integration-features = "ssh-env,ssh-terminfo,no-cursor";
        };
        themes = {
          clean = {
            background = "#000000";
            cursor-color = "#f5e0dc";
            foreground = "#cdd6f4";
            selection-background = "353749";
            selection-foreground = "cdd6f4";
            palette = [
              "0=#000000"
              "1=#eb4129"
              "2=#abe047"
              "3=#f6c744"
              "4=#47a0f3"
              "5=#7b5cb0"
              "6=#64dbed"
              "7=#ffffff"
              "8=#565656"
              "9=#ec5357"
              "10=#c0e17d"
              "11=#f9da6a"
              "12=#49a4f8"
              "13=#a47de9"
              "14=#99faf2"
              "15=#ffffff"
            ];
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
      remmina.enable = true;
      network-manager-applet.enable = true;
      nextcloud-client = {
        enable = false;
        startInBackground = false;
      };
    };
  };
}
