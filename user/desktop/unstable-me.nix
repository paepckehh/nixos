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
    systemPackages = with pkgs.unstable; [gparted mission-center keepassxc];
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    services = {
      remmina.enable = false;
    };
    programs = {
      librewolf = {
        enable = true;
        package = pkgs.unstable.librewolf;
        settings = {
          # "identity.fxaccounts" = true;
          # "identity.fxaccounts.autoconfig.uri" = "https://localhost:5000";
          "browser.cache.disk.enable" = false;
          "browser.compactmode.show" = true;
          "browser.startup.homepage" = "";
          "signon.rememberSignons" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "media.ffmpeg.vaapi.enabled" = true;
          "webgl.disabled" = false;
        };
      };
      alacritty = {
        enable = true;
        package = pkgs.unstable.alacritty;
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
              black = "#2e2e2e";
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
  };
}
