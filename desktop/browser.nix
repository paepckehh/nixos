{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    cage = {
      enable = true;
      user = "kiosk";
      program = lib.mkDefault "${pkgs.librewolf}/bin/librewolf";
    };
    autosuspend.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
    pipewire = {
      enable = lib.mkForce false;
      pulse.enable = lib.mkForce false;
      wireplumber.enable = lib.mkForce false;
      alsa.enable = lib.mkForce false;
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      kiosk = {
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7"; # start
        description = "kiosk";
        uid = 65501;
        createHome = true;
        isNormalUser = true;
        group = "kiosk";
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
    groups.kiosk = {};
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.kiosk = {
    home = {
      stateVersion = config.system.nixos.release;
      enableNixpkgsReleaseCheck = false;
      keyboard.layout = "de,us";
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
      };
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = lib.mkForce false;
}
