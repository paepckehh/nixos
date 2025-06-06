{
  pkgs,
  lib,
  ...
}: {
  ################
  # HOME-MANAGER #
  ################
  home-manager.users.me.programs = {
    firefox = {
      enable = true;
      # package = pkgs.librewolf-beta;
      nativeMessagingHosts = [pkgs.keepassxc];
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
          # "general.useragent.override" = "Mozilla/5.0 (X11; Linux x86_64; rv:139.0) Gecko/20100101 Firefox/139.0";
          # "general.useragent.override" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:139.0) Gecko/20100101 Firefox/139.0";
          "general.useragent.override" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:139.0) Gecko/20100101 Firefox/139.0";
          "general.useragent.compatMode.firefox" = true;
          "general.useragent.locale" = "en-US";
          "browser.aboutConfig.showWarning" = false;
          "browser.bookmarks.showMobileBookmarks" = true;
          "browser.bookmarks.restore_default_bookmarks" = true;
          "browser.cache.disk.enable" = false;
          "browser.compactmode.show" = true;
          "browser.policies.runOncePerModification.removeSearchEngines" = "Google";
          "browser.policies.runOncePerModification.setDefaultSearchEngine" = "DuckDuckGo";
          "browser.safebrowsing.enabled" = false;
          "browser.safebrowsing.downloads.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "browser.search.region" = "DE";
          "browser.search.update" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.sessionstore.restore_on_demand" = false;
          "browser.sessionstore.resume_from_crash" = false;
          "browser.sessionstore.resuming_after_os_restart" = false;
          "browser.sessionstore.privacy_level" = 2;
          "browser.fullscreen.autohide" = false;
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
          "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
          "cookiebanners.service.mode" = 2; # Block cookie banners
          "distribution.searchplugins.defaultLocale" = "en-US";
          "dom.security.sanitizer.enabled" = true;
          "dom.push.enabled" = false;
          "dom.push.connection.enabled" = false;
          "dom.push.serverURL" = "";
          "dom.push.indicate_aesgcm_support.enabled" = true;
          "geo.enabled" = false;
          "geo.provider.geoclue.always_high_accuracy" = false;
          "geo.provider.network.url" = ""; # https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%
          "geo.provider.use_corelocation" = false;
          "geo.provider.use_geoclue" = false;
          "geo.provider.use_gpsd" = false;
          "gfx.webrender.all" = true;
          "security.tls.grease_http3_enable" = true;
          "layers.acceleration.force-enabled" = true;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.server" = "https://false.lan";
          "media.ffmpeg.vaapi.enabled" = true;
          "network.proxy.type" = 0;
          "network.trr.mode" = 0;
          "network.connectivity-service.enabled" = false;
          "network.connectivity-service.IPv4.url" = "";
          "network.connectivity-service.IPv6.url" = "";
          "network.connectivity-service.DNSv4.domain" = "";
          "network.connectivity-service.DNSv6.domain" = "";
          "network.connectivity-service.DNS_HTTPS.domain" = "";
          "network.dns.echconfig.enabled" = true;
          "network.dns.disableIPv6" = true;
          "network.dns.preferIPv6" = false;
          "network.dns.http3.echconfig.enabled" = true;
          "network.wifi.scanning_period" = 0;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.firstparty.isolate" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "reader.parse-on-load.force-enabled" = true;
          "signon.rememberSignons" = false;
          "webgl.disabled" = false;
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
        NoDefaultBookmarks = false;
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
          "readeck@readeck.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/readeck/latest.xpi";
            installation_mode = "force_installed";
          };
          "floccus@floccus.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/floccus/latest.xpi";
            installation_mode = "force_installed";
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
        RequestedLocales = "en-US";
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
