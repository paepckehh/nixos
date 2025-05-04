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
  ];

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            toggle-alacritty.extensionUuid
          ];
          favorite-apps = ["Alacritty.desktop" "librewolf.desktop" "org.keepassxc.KeePassXC.desktop"];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "alacritty terminal"; # <windows-key> + <return> = terminal
          command = "alacritty";
          binding = "<Super>Return";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          name = "librewolf browser not-sandboxed"; # <windows-key> +  <b> = browser
          command = "librewolf";
          binding = "<Super>b";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          name = "keepassxc passwordmanager"; # <windows-key> +  <k> = keepassxc
          command = "keepassxc";
          binding = "<Super>k";
        };
        "org/gnome/desktop/interface" = {
          clock-show-weekday = true;
        };
      };
    };
    programs = {
      librewolf = {
        enable = true;
        policies = {
          DontCheckDefaultBrowser = true;
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableFirefoxScreenshots = true;
          HardwareAcceleration = true;
          PictureInPicture.Enabled = false;
          PromptForDownloadLocation = false;
          TranslateEnabled = false;
          OverrideFirstRunPage = "";
          NoDefaultBookmarks = true;
          ManagedBookmarks = lib.importJSON ./resources/bookmarks-corp.json;
          ExtensionSettings = {
            "*".installation_mode = "blocked";
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
          };
          SanitizeOnShutdown = {
            Cache = true;
            Cookies = true;
            Downloads = true;
            FormData = true;
            History = true;
            Sessions = true;
            SiteSettings = true;
            OfflineApps = true;
          };
        };
        profiles = {
          default = {
            id = 0;
            name = "DefaultProfile";
            isDefault = true;
          };
        };
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.cache.disk.enable" = false;
          "browser.compactmode.show" = true;
          "browser.startup.homepage" = "";
          "browser.search.defaultenginename" = "DuckDuckGo";
          "browser.search.order.1" = "DuckDuckGo";
          "gfx.webrender.all" = true;
          "reader.parse-on-load.force-enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "signon.rememberSignons" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.firstparty.isolate" = true;
          "privacy.resistFingerprinting" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "network.trr.mode" = 0;
          "network.proxy.type" = 0;
          "webgl.disabled" = false;
          "widget.disable-workspace-management" = true;
        };
        search = {
          force = true;
          default = "DuckDuckGo";
          order = ["DuckDuckGo" "Google"];
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
    };
    services = {
      remmina.enable = false;
    };
  };
}
