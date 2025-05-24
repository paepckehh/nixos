{
  pkgs,
  lib,
  ...
}: {
  home-manager.users.me.programs = {
    firefox = {
      enable = true;
      package = pkgs.librewolf;
      # nativeMessagingHosts = [pkgs.keepassxc];
      profiles."0" = {
        id = 0;
        isDefault = true;
        name = "0";
        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";
          engines = {
            np = {
              name = "NixOS Packages";
              urls = [{template = "https://search.nixos.org/packages?channel=unstable&size=100&sort=alpha_asc&type=options&query={searchTerms}";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };
            no = {
              name = "NixOS Options";
              urls = [{template = "https://search.nixos.org/options?channel=unstable&size=100&sort=alpha_asc&type=options&query={searchTerms}";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@no"];
            };
            nh = {
              name = "NixOS Home-Manager";
              urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}%5C&release=master";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@nh"];
            };
            nw = {
              name = "NixOS Wiki";
              urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@nw"];
            };
          };
        };
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.bookmarks.showMobileBookmarks" = true;
          "browser.cache.disk.enable" = false;
          "browser.compactmode.show" = true;
          "browser.policies.runOncePerModification.removeSearchEngines" = "Google";
          "browser.policies.runOncePerModification.setDefaultSearchEngine" = "DuckDuckGo";
          "browser.search.region" = "DE";
          "browser.search.update" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.urlbar.quicksuggest.enabled" = false;
          "browser.urlbar.shortcuts.bookmarks" = true;
          "browser.urlbar.shortcuts.history" = true;
          "browser.urlbar.shortcuts.tabs" = true;
          "browser.urlbar.suggest.addons" = false;
          "browser.urlbar.suggest.bookmark" = true;
          "browser.urlbar.suggest.calculator" = true;
          "browser.urlbar.suggest.clipboard" = true;
          "browser.urlbar.suggest.engines" = true;
          "browser.urlbar.suggest.history" = true;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.pocket" = false;
          "browser.urlbar.suggest.quickaction" = false;
          "browser.urlbar.suggest.recentsearches" = false;
          "browser.urlbar.suggest.remotetab" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.suggest.trending" = false;
          "browser.urlbar.suggest.weather" = false;
          "browser.urlbar.suggest.yelp" = false;
          "browser.urlbar.speculativeConnect.enabled" = false;
          "browser.urlbar.trimHttps" = false;
          "browser.urlbar.trimURLs" = false;
          "browser.urlbar.unifiedSearchButton.always" = true;
          "browser.urlbar.unitConversion.enabled" = true;
          "distribution.searchplugins.defaultLocale" = "en-US";
          "general.useragent.locale" = "en-US";
          "geo.enabled" = false;
          "geo.provider.geoclue.always_high_accuracy" = false;
          "geo.provider.network.url" = ""; # https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%
          "geo.provider.use_corelocation" = false;
          "geo.provider.use_geoclue" = false;
          "geo.provider.use_gpsd" = false;
          "gfx.webrender.all" = true;
          "layers.acceleration.force-enabled" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "network.proxy.type" = 0;
          "network.trr.mode" = 0;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.firstparty.isolate" = true;
          "privacy.resistFingerprinting" = true;
          "reader.parse-on-load.force-enabled" = true;
          "signon.rememberSignons" = false;
          "webgl.disabled" = false;
          "widget.disable-workspace-management" = true;
        };
      };
      policies = {
        BackgroundAppUpdate = false;
        CaptivePortal = false;
        DisableAccounts = true;
        DisableBuiltinPDFViewer = false;
        DisableTelemetry = true;
        DisableDeveloperTools = false;
        DisableEncryptedClientHello = false;
        DisableFeedbackCommands = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisableForgetButton = false;
        DisableFormHistory = false;
        DisableMasterPasswordCreation = false;
        DisablePasswordReveal = false;
        DisablePocket = true;
        DisablePrivateBrowsing = false;
        DisableProfileImport = true;
        DisableProfileRefresh = true;
        DisableSafeMode = false;
        DisableSecurityBypass.InvalidCertificate = false;
        DisplayBookmarksToolbar = "always";
        DNSOverHTTPS.Enabled = false;
        DontCheckDefaultBrowser = true;
        HttpAllowlist = ["http://start.lan" "http://localhost" "http://127.0.0.1" "http://192.168.0.1" "http://192.186.1.1" "http://192.168.8.1" "http://192.168.80.1"];
        HttpsOnlyMode = "force_enabled"; # "force_enabled"
        HardwareAcceleration = true;
        NetworkPrediction = false;
        NewTabPage = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        PasswordManagerEnabled = false;
        PostQuantumKeyAgreementEnabled = true;
        SearchSuggestEnabled = false;
        ShowHomeButton = true;
        SkipTermsOfUse = true;
        SSLVersionMax = "tls1.3";
        SSLVersionMin = "tls1.2";
        StartDownloadsInTempDirectory = true;
        TranslateEnabled = false;
        ManagedBookmarks = lib.importJSON ../../shared/bookmarks-global.json;
        Permissions = {
          Notifications = {
            BlockNewRequests = true;
            Locked = true;
          };
          Autoplay = {
            BlockNewRequests = true;
            Locked = true;
          };
        };
        ExtensionSettings = {
          "*".installation_mode = "blocked";
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            adminSettings = {
              userSettings = {
                uiTheme = "dark";
                uiAccentCustom = true;
                uiAccentCustom0 = "#8300ff";
                cloudStorageEnabled = false;
              };
            };
          };
          "keepassxc-browser@keepass.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        PrintingEnabled = true;
        PrivateBrowsingModeAvailability = 1;
        PromptForDownloadLocation = true;
        Proxy.Mode = "none";
        RequestedLocales = "en-US,en,de";
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
    };
  };
}
