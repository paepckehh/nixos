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
    ../../client/addHomeFix.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [adwaita-icon-theme];

  ##################
  #-=# SECURITY #=-#
  ##################
  security.pam.services.me.enableGnomeKeyring = true;

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
            "org.remmina.Remmina.desktop"
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
      };
    };
    programs = {
      element-desktop = {
        enable = true;
        settings = {
          default_server_config = {
            "m.homeserver" = {
              base_url = infra.matrix.url;
              server_name = "${infra.site.name}TALK";
            };
            "m.identity_server" = {
              base_url = "https://vector.im";
            };
          };
          disable_custom_urls = false;
          disable_guests = false;
          disable_login_language_selector = false;
          disable_3pid_login = false;
          force_verification = false;
          brand = "Element";
          integrations_ui_url = "https://scalar.vector.im/";
          integrations_rest_url = "https://scalar.vector.im/api";
        };
      };
      onlyoffice = {
        enable = false;
        settings = {
          editorWindowMode = "false";
          locale = infra.locale.lang;
          maximized = true;
          titlebar = "Start";
        };
      };
      thunderbird = {
        enable = true;
        package = pkgs.thunderbird;
        settings = infra.thunderbird.settings;
        profiles.default = {
          isDefault = true;
          settings = infra.thunderbird.settings;
        };
      };
      librewolf = {
        enable = true;
        languagePacks = ["de"];
        settings = infra.firefox.settings;
        package = pkgs.librewolf.override {nativeMessagingHosts = [pkgs.gnome-browser-connector];};
        policies = lib.recursiveUpdate infra.firefox.policy bookmarks;
        profiles.default = {
          isDefault = true;
          settings = infra.firefox.settings;
        };
      };
      ghostty = {
        enable = false;
        installBatSyntax = true;
        installVimSyntax = true;
        systemd.enable = true;
        settings = {
          language = infra.locale.lang;
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
      yazi = {
        enable = true;
        enableFishIntegration = true;
        # extraPackages = with pkgs.yaziPlugins; [chmod compress diff gvfs lsar ouch mediainfo mime-ext rsync starship time-travel];
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
