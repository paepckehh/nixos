{
  pkgs,
  lib,
  ...
}: {
  programs = {
    firefox = {
      enable = true;
      # package = pkgs.librewolf;
      # nativeMessagingHosts = [pkgs.keepassxc];
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
        NewTabPage = true;
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
        ManagedBookmarks = lib.importJSON ../shared/bookmarks-global.json;
        SearchEngines = {
          Default = "DuckDuckGo";
          Remove = ["Google" "Bing"];
          Add = [
            {
              Alias = "@np";
              Description = "Search in NixOS Packages";
              IconURL = "https://nixos.org/favicon.png";
              Method = "GET";
              Name = "NixOS Packages";
              URLTemplate = "https://search.nixos.org/packages?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
            }
            {
              Alias = "@no";
              Description = "Search in NixOS Options";
              IconURL = "https://nixos.org/favicon.png";
              Method = "GET";
              Name = "NixOS Options";
              URLTemplate = "https://search.nixos.org/options?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
            }
          ];
        };
        Permissions = {
          Camera = {
            BlockNewRequests = true;
            Locked = true;
          };
          Microphone = {
            BlockNewRequests = true;
            Locked = true;
          };
          Location = {
            BlockNewRequests = true;
            Locked = true;
          };
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
      preferencesStatus = "locked";
      preferences = {
        "browser.aboutConfig.showWarning" = false;
        "browser.cache.disk.enable" = false;
        "browser.compactmode.show" = true;
        "browser.startup.homepage" = "";
        "browser.search.update" = false;
        # "browser.search.defaultenginename" = "DuckDuckGo";
        # "browser.search.order.1" = "DuckDuckGo";
        "browser.policies.runOncePerModification.removeSearchEngines" = "Google";
        "browser.policies.runOncePerModification.setDefaultSearchEngine" = "DuckDuckGo";
        "browser.urlbar.trimHttps" = false;
        "browser.urlbar.trimURLs" = false;
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
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.suggest.weather" = false;
        "browser.urlbar.suggest.yelp" = false;
        "browser.urlbar.unifiedSearchButton.always" = true;
        "browser.urlbar.unitConversion.enabled" = true;
        "gfx.webrender.all" = true;
        "geo.enabled" = false;
        "geo.provider.use_corelocation" = false;
        "geo.provider.use_geoclue" = false;
        "geo.provider.use_gpsd" = false;
        "geo.provider.network.url" = ""; # https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%
        "geo.provider.geoclue.always_high_accuracy" = false;
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
}
