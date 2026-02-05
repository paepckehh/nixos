{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../../siteconfig/config.nix).infra;
in {
  services.gnome.gnome-browser-connector.enable = true;
  ################
  # HOME-MANAGER #
  ################
  home-manager.users.me.programs.librewolf = {
    enable = true;
    languagePacks = ["de" "Deutsch"];
    # package = pkgs.firefox;
    # package = pkgs.librewolf;
    package = pkgs.librewolf.override {nativeMessagingHosts = [pkgs.gnome-browser-connector];};
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
      GoToIntranetSiteForSingleWordEntryInAddressBar = false;
      Homepage = {
        URL = infra.portal.url;
        Locked = true;
        StartPage = "homepage";
      };
      NetworkPrediction = false;
      NewTabPage = false;
      NoDefaultBookmarks = false;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      PasswordManagerEnabled = false;
      PostQuantumKeyAgreementEnabled = true;
      ShowHomeButton = true;
      SkipTermsOfUse = true;
      SSLVersionMax = "tls1.3";
      SSLVersionMin = "tls1.2";
      StartDownloadsInTempDirectory = true;
      TranslateEnabled = false;
      ManagedBookmarks = lib.importJSON ../../../shared/bookmarks.json;
      Permissions.Autoplay.BlockNewRequests = true;
      ExtensionSettings = {
        "*".installation_mode = "blocked";
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
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
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/readeck/latest.xpi";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        };
      };
      PrintingEnabled = true;
      # PromptForDownloadLocation = true;
      # PrivateBrowsingModeAvailability = 1;
      # RequestedLocales = ["de" "en" "en-US"];
      Proxy = {
        Mode = "none"; #  "none" | "system" | "manual" | "autoDetect" | "autoConfig"
        # AutoConfigURL = infra.wpad.url;
        # Locked = false;
        # UseHTTPProxyForAllProtocols = true;
      };
      SearchEngines = {
        Default = "SearX";
        Add = [
          {
            Name = "SearX";
            Alias = "ds";
            Description = "Internal-Search-Engine";
            Method = "GET";
            URLTemplate = infra.search.urls.search;
            SuggestURLTemplate = infra.search.urls.suggest;
            IconURL = infra.search.logo;
          }
        ];
      };
      SanitizeOnShutdown = {
        Cache = true;
        Cookies = false;
        Downloads = true;
        FormData = true;
        History = true;
        Sessions = false;
        SiteSettings = false;
        OfflineApps = false;
      };
      UserMessaging = {
        ExtensionRecommendation = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = false;
        Locked = false;
      };
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };
      GenerativeAI = {
        Enabled = false;
        Chatbot = false;
        LinkPreviews = false;
        TabGroups = false;
        Locked = true;
      };
    };
    settings = {
      "privacy.privacy.resistFingerprinting.exemptedDomains" = "*.home.corp";
    };
    profiles.default = {
      id = 0;
      isDefault = true;
      name = "0";
      settings = {
        "browser.bookmarks.restore_default_bookmarks" = true;
        "distribution.searchplugins.defaultLocale" = "de";
        # "general.useragent.locale" = "de";
        # "browser.search.region" = "de";
        # "privacy.resistFingerprinting" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.firstparty.isolate" = true;
        "privacy.privacy.resistFingerprinting.exemptedDomains" = "*.home.corp";
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "general.useragent.compatMode.firefox" = true;
        "general.autoScroll" = true;
        "browser.aboutConfig.showWarning" = false;
        "browser.bookmarks.showMobileBookmarks" = true;
        "browser.cache.disk.enable" = false;
        "browser.compactmode.show" = true;
        "browser.policies.runOncePerModification.removeSearchEngines" = "Google";
        "browser.policies.runOncePerModification.setDefaultSearchEngine" = "debisearch";
        "browser.safebrowsing.enabled" = false;
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.search.update" = false;
        "browser.startup.homepage" = "https://start.dbt.corp";
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
        "dom.push.enabled" = false;
        "dom.push.connection.enabled" = false;
        "dom.push.serverURL" = "";
        "dom.push.indicate_aesgcm_support.enabled" = true;
        "geo.enabled" = false;
        "geo.provider.geoclue.always_high_accuracy" = false;
        "geo.provider.network.url" = "";
        "geo.provider.use_corelocation" = false;
        "geo.provider.use_geoclue" = false;
        "geo.provider.use_gpsd" = false;
        "security.tls.grease_http3_enable" = true;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.server" = "https://false.lan";
        "network.proxy.type" = 4;
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
        "browser.tabs.groups.smart.enabled" = false;
        "browser.ml.enabled" = false;
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.sidebar" = false;
        "browser.ml.chat.shortcuts" = false;
        "browser.ml.chat.menu" = false;
        "browser.ml.linkPreview.enable" = false;
        "browser.ml.modelHubRootUrl" = "http://localhost";
      };
    };
  };
}
