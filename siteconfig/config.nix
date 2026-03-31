let
  ################
  #-=# INFRA  #=-#
  ################
  infra = {
    site = {
      id = 50; # site/company id, range 1-256
      name = "home"; # site/company name
      displayName = "Home Lab - Paepcke";
      type = "private"; # private, business, validation, mobile
      domain = {
        tld = "corp";
        name = infra.site.name;
        extern = "paepcke.de";
      };
      networkrange = {
        oct1 = 10; # prefix
        oct2 = infra.site.id; # result => scope <intranet> 10.50.0.0/16
      };
      cloudName = {
        admin = "IT-ADMIN-HOMECLOUD";
        user = "HOMECLOUD";
      };
    };
    locale = {
      tz = "Europe/Berlin";
      keymap = "us"; # de
      lang = "en"; # de
      upper = "EN";
      LC = {
        global = "C.UTF-8"; # C.UTF-8 en_US.UTF-8 de_DE.UTF-8
        regional = "de_DE.UTF-8"; # adddress, phone, money
      };
    };
    email.domain = {
      intern = infra.domain.user;
      extern = infra.site.domain.extern;
    };
    admin = {
      name = "admin";
      displayName = "IT-TEAM@${infra.site.site.cloudName.admin}";
      email = "it@${infra.email.domain.intern}";
      smtp = {
        id = "it";
        pwd = "password";
      };
      sshKeys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIG50evljqeCBDwrkkB0FXf9A2BtCKYnDYHOnHZvpmRLNAAAABHNzaDo= me@ops"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAGsgOTEwxqUCKC49pwuQHXyhb+jjIBUzFdwRsjS9iMkAAAABHNzaDo= git@paepcke.de"
      ];
    };
    backup = {
      email = "backup@${infra.email.domain.intern}";
      sshKeys = [
        "ssh-ed25519@openssh.com [...] ="
      ];
    };
    storage = {
      persist = "/nix/persist";
      cache = "${infra.storage.persist}/cache";
      state = "/var/lib";
    };
    sources = {
      prefix = infra.sources.mirror;
      github = "github:";
      git-mirror = "git+${infra.git-mirror.url}/";
      local = "git+file://${infra.git-mirror.storage}/";
      repos = {
        agenix.url = "${infra.sources.prefix}ryan/agenix.git?ref=main";
        disko.url = "${infra.sources.prefix}nix-community/disko.git?ref=master";
        nixpkgs.url = "${infra.sources.prefix}nixos/nixpkgs.git?ref=nixos-unstable";
        home-manager.url = "${infra.sources.prefix}nix-community/home-manager.git?ref=master";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    true = "true";
    false = "false";
    none = "none";
    one = "1";
    log = {
      trace = "trace";
      debug = "debug";
      info = "info";
      warn = "warn";
    };
    go.cache = "${infra.storage.cache}/go";
    localhost = {
      name = "localhost";
      ip = "127.0.0.1";
      cidr = "127.0.0.0/24";
      port.offset = 7000;
      metric.offset = 9000;
    };
    container.interface = "br0";
    id = {
      admin = 0;
      bridge = 70;
      container = 80;
      user = 6;
      remote = 66;
      virtual = 99;
    };
    vlan = {
      admin = infra.id.admin;
      bridge = infra.id.bridge;
      container = infra.id.container;
      user = infra.id.user;
      remote = infra.id.remote;
      virtual = infra.id.virtual;
    };
    net = {
      prefix = "${toString infra.site.networkrange.oct1}.${toString infra.site.networkrange.oct2}";
      admin = "${infra.net.prefix}.${toString infra.id.admin}";
      bridge = "${infra.net.prefix}.${toString infra.id.bridge}";
      container = "${infra.net.prefix}.${toString infra.id.container}";
      user = "${infra.net.prefix}.${toString infra.id.user}";
      remote = "${infra.net.prefix}.${toString infra.id.remote}";
      virtual = "${infra.net.prefix}.${toString infra.id.virtual}";
    };
    cidr = {
      netmask = 23;
      admin = "${infra.net.admin}.0/${toString infra.cidr.netmask}"; # 10.50.0.0/23
      bridge = "${infra.net.bridge}.0/${toString infra.cidr.netmask}"; # 10.50.70.0/23
      container = "${infra.net.container}.0/${toString infra.cidr.netmask}"; # 10.50.80.0/23
      user = "${infra.net.user}.0/${toString infra.cidr.netmask}"; # 10.50.6.0/23
      remote = "${infra.net.remote}.0/${toString infra.cidr.netmask}"; # 10.50.66.0/23
      clients = "${infra.cidr.user} ${infra.cidr.remote}";
      all = "${infra.cidr.admin} ${infra.cidr.container} ${infra.cidr.user} ${infra.cidr.remote} ${infra.cidr.podman} ${infra.localhost.cidr}";
      allArray = [infra.cidr.admin infra.cidr.container infra.cidr.user infra.cidr.remote infra.cidr.podman infra.localhost.cidr];
      clientsArray = [infra.cidr.user infra.cidr.remote infra.localhost.cidr];
      podman = "10.88.0.0/16";
    };
    domain = {
      tld = infra.site.domain.tld;
      domain = "${infra.domain.tld}"; # corp
      user = "${infra.site.name}.${infra.domain.tld}"; # home.corp
      admin = "${infra.zonename.admin}.${infra.domain.user}"; # admin.home.corp
      bridge = "${infra.zonename.bridge}.${infra.domain.user}"; # container.home.corp
      container = "${infra.zonename.container}.${infra.domain.user}"; # container.home.corp
      remote = "${infra.zonename.remote}.${infra.domain.user}"; # remote.home.corp
      virtual = "${infra.zonename.virtual}.${infra.domain.user}"; # virtual.home.corp
    };
    zonename = {
      admin = "admin";
      bridge = "bridge";
      container = "container";
      user = "user";
      remote = "remote";
      virtual = "virtual";
    };
    namespace = {
      prefix = "";
      admin = "0${infra.namespace.prefix}${toString infra.id.admin}-${infra.zonename.admin}";
      bridge = "${infra.namespace.prefix}${toString infra.id.bridge}-${infra.zonename.bridge}";
      container = "${infra.namespace.prefix}${toString infra.id.container}-${infra.zonename.container}";
      user = "0${infra.namespace.prefix}${toString infra.id.user}-${infra.zonename.user}";
      remote = "${infra.namespace.prefix}${toString infra.id.remote}-remote";
    };
    port = {
      dns = 53;
      https = 443;
      smtp = 25;
      ssh = 6622;
      ssh-mgmt = 6623;
      http = 80;
      imap = 143;
      jmap = 143;
      syslog = 514;
      ldap = 3890;
      smb = {
        quic = 443;
        tcp = 445;
      };
      proxy = 3128;
      webapps = [infra.port.http infra.port.https];
    };
    proxies = {
      http = [];
      https = [];
    };
    caldav = {
      name = "caldav";
      fqdn = "${infra.caldav.name}.${infra.domain.user}";
    };
    opn = {
      standby = ["01"];
      infra = ["02" "03"];
      firewall = ["11" "12" "13"];
      adminport = {
        https = "8443";
        ssh = "6622";
      };
      logo = "${infra.res.url}/icon/png/borg.png";
    };
    proxy = {
      one.uri = "${infra.net.user}.11:${toString infra.port.proxy}";
      two.uri = "${infra.net.user}.12:${toString infra.port.proxy}";
      three.uri = "${infra.net.user}.13:${toString infra.port.proxy}";
    };
    print = {
      app = "cups";
      url = "http://localhost:631/";
      logo = "${infra.res.url}/icon/png/printer.png";
    };
    thunderbird = {
      settings = infra.firefox.settings;
      policy = {
        # Certificates.Install."mailCA.der" = "/etc/mailCA.pem";
        DisableTelemetry = true;
        HardwareAcceleration = false;
        NetworkPrediction = false;
        RequestedLocales = "de";
        Preferences = infra.firefox.settings;
        DNSOverHTTPS = {
          Enabled = false;
          Locked = true;
        };
        ExtensionSettings = {
          "*".installation_mode = "blocked";
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/ublock-origin/latest.xpi";
          };
        };
        Proxy = {
          Mode = "none"; # XXX "none" | "system" | "manual" | "autoDetect" | "autoConfig"
          AutoConfigURL = infra.wpad.url;
        };
        SearchEngines = {
          Default = "${infra.search.label}";
          Add = [
            {
              Name = "${infra.search.label}";
              Alias = "ds";
              Description = "Internal-Search-Engine";
              Method = "GET";
              URLTemplate = infra.search.urls.search;
              SuggestURLTemplate = infra.search.urls.suggest;
              IconURL = infra.search.logo;
            }
          ];
        };
      };
    };
    firefox = {
      policy = {
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
          StartPage = "Start";
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
        Proxy = {
          Mode = "none"; # XXX "none" | "system" | "manual" | "autoDetect" | "autoConfig"
          AutoConfigURL = infra.wpad.url;
        };
        SearchEngines = {
          Default = "${infra.search.label}";
          Add = [
            {
              Name = "${infra.search.label}";
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
      };
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.bookmarks.restore_default_bookmarks" = true;
        "browser.bookmarks.showMobileBookmarks" = true;
        "browser.cache.disk.enable" = false;
        "browser.cache.disk_cache_ssl" = false;
        "browser.compactmode.show" = true;
        "browser.fullscreen.autohide" = false;
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.menu" = false;
        "browser.ml.chat.shortcuts" = false;
        "browser.ml.chat.sidebar" = false;
        "browser.ml.enabled" = false;
        "browser.ml.linkPreview.enable" = false;
        "browser.ml.modelHubRootUrl" = "";
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.policies.runOncePerModification.setDefaultSearchEngine" = "${infra.search.label}";
        "browser.safebrowsing.downloads.enabled" = false;
        "browser.safebrowsing.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.search.region" = infra.locale.lang;
        "browser.search.update" = false;
        "browser.sessionstore.privacy_level" = 2;
        "browser.sessionstore.restore_on_demand" = false;
        "browser.sessionstore.resume_from_crash" = false;
        "browser.sessionstore.resuming_after_os_restart" = false;
        "browser.startup.homepage" = "${infra.portal.url}";
        "browser.tabs.groups.smart.enabled" = false;
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.shortcuts.bookmarks" = true;
        "browser.urlbar.shortcuts.history" = true;
        "browser.urlbar.shortcuts.tabs" = true;
        "browser.urlbar.speculativeConnect.enabled" = false;
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
        "browser.urlbar.trimHttps" = false;
        "browser.urlbar.trimURLs" = false;
        "browser.urlbar.unifiedSearchButton.always" = true;
        "browser.urlbar.unitConversion.enabled" = true;
        "cookiebanners.service.mode" = 2;
        "cookiebanners.service.mode.privateBrowsing" = 2;
        "datareporting.dau.cachedUsageProfileGroupID" = "";
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.sessions.current.clean" = true;
        "devtools.onboarding.telemetry.logged" = false;
        "distribution.searchplugins.defaultLocale" = infra.locale.lang;
        "dom.push.connection.enabled" = false;
        "dom.push.enabled" = false;
        "dom.push.indicate_aesgcm_support.enabled" = true;
        "dom.push.serverURL" = "";
        "general.autoScroll" = true;
        "general.useragent.compatMode.firefox" = true;
        "geo.enabled" = false;
        "geo.provider.geoclue.always_high_accuracy" = false;
        "geo.provider.network.url" = "";
        "geo.provider.use_corelocation" = false;
        "geo.provider.use_geoclue" = false;
        "geo.provider.use_gpsd" = false;
        "gfx.canvas.accelerated" = false;
        "intl.locale.requested" = infra.locale.lang;
        "network.connectivity-service.DNS_HTTPS.domain" = "";
        "network.connectivity-service.DNSv4.domain" = "";
        "network.connectivity-service.DNSv6.domain" = "";
        "network.connectivity-service.IPv4.url" = "";
        "network.connectivity-service.IPv6.url" = "";
        "network.connectivity-service.enabled" = false;
        "network.dns.disableIPv6" = true;
        "network.dns.echconfig.enabled" = true;
        "network.dns.http3.echconfig.enabled" = true;
        "network.dns.preferIPv6" = false;
        "network.proxy.type" = 4;
        "network.trr.mode" = 0;
        "network.wifi.scanning_period" = 0;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.firstparty.isolate" = true;
        "privacy.privacy.resistFingerprinting.exemptedDomains" = "*.${infra.domain.tld}";
        "privacy.resistFingerprinting" = false;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "security.tls.ech.grease_http3" = true;
        "security.tls.enable_0rtt_data" = false;
        "security.tls.enable_certificate_compression_abridged" = false;
        "security.tls.enable_certificate_compression_brotli" = false;
        "security.tls.enable_certificate_compression_zlib" = false;
        "security.tls.enable_certificate_compression_zstd" = false;
        "security.tls.enable_delegated_credentials" = false;
        "security.tls.enable_kyber" = true;
        "security.tls.enable_post_handshake_auth" = false;
        "security.tls.grease_http3_enable" = true;
        "security.tls.hello_downgrade_check" = true;
        "security.tls.version.enable-deprecated" = false;
        "security.tls.version.fallback-limit" = 4;
        "security.tls.version.max" = 4; # 1.3
        "security.tls.version.min" = 3; # 1.2
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.prompted" = "2";
        "toolkit.telemetry.rejected" = true;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.unifiedIsOptIn" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "webgl.forbid-hardware" = true;
      };
    };
    smbgate = {
      id = 24;
      name = "smbgate";
      hostname = infra.smbgate.name;
      domain = infra.domain.user;
      fqdn = "${infra.smbgate.hostname}.${infra.smbgate.domain}";
      ip = "${infra.net.user}.${toString infra.smbgate.id}";
      localbind.port.http = infra.localhost.port.offset + infra.smbgate.id;
      lock.interface = "user-vlan@br0";
      url = "https://${infra.smbgate.fqdn}";
      logo = "${infra.res.url}/icon/png/samba-server.png";
      # XXX samba users need statefull init - do additional: sudo sh ; smbpasswd -a <user>
      users = {
        "it" = {
          initialHashedPassword = null;
          openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
          description = "samba user for ti share";
          group = "ti";
          createHome = false;
          extraGroups = ["users"];
          isNormalUser = true;
        };
        "ti" = {
          initialHashedPassword = null;
          openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
          description = "samba user for ti share";
          group = "ti";
          createHome = false;
          extraGroups = ["users"];
          isNormalUser = true;
        };
        "fb" = {
          initialHashedPassword = null;
          openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
          description = "samba user for fb share";
          group = "fb";
          createHome = false;
          extraGroups = ["users"];
          isNormalUser = true;
        };
        "fe" = {
          initialHashedPassword = null;
          openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
          description = "samba user for fa share";
          group = "fe";
          createHome = false;
          extraGroups = ["users"];
          isNormalUser = true;
        };
        "op" = {
          initialHashedPassword = null;
          openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
          description = "samba user for op share";
          group = "op";
          createHome = false;
          extraGroups = ["users"];
          isNormalUser = true;
        };
      };
      groups = {
        "it".members = ["it"];
        "ti".members = ["it"];
        "fb".members = ["fb"];
        "fe".members = ["fe"];
        "op".members = ["op"];
      };
      shares = {
        "it" = {
          "browseable" = "no";
          "comment" = "IT DataExchange";
          "path" = "/nix/persist/mnt/it";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "it";
          "force group" = "it";
          "valid users" = "it";
        };
        "ti" = {
          "browseable" = "no";
          "comment" = "TI DataExchange";
          "path" = "/nix/persist/mnt/ti";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "ti";
          "force group" = "i";
          "valid users" = "ti";
        };
        "fb" = {
          "browseable" = "no";
          "comment" = "FB DataExchange";
          "path" = "/nix/persist/mnt/fb";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "fb";
          "force group" = "fb";
          "valid users" = "fb";
        };
        "fe" = {
          "browseable" = "no";
          "comment" = "FE DataExchange";
          "path" = "/nix/persist/mnt/fe";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "fe";
          "force group" = "fe";
          "valid users" = "fe";
        };
        "op" = {
          "browseable" = "no";
          "comment" = "OP DataExchange";
          "path" = "/nix/persist/mnt/op";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "op";
          "force group" = "op";
          "valid users" = "op";
        };
      };
      mountpoints = [
        "d /nix/persist/mnt/it 0770 it it - -"
        "d /nix/persist/mnt/ti 0770 ti ti - -"
        "d /nix/persist/mnt/fa 0770 fe fe - -"
        "d /nix/persist/mnt/fa 0770 fb fb - -"
        "d /nix/persist/mnt/fa 0770 op op - -"
      ];
    };
    smtp = {
      id = 25;
      hostname = "smtp";
      domain = infra.smtp.user.domain;
      ip = infra.smtp.user.ip;
      fqdn = infra.smtp.user.fqdn;
      uri = infra.smtp.user.uri;
      admin = {
        domain = infra.domain.admin;
        namespace = infra.namespace.admin;
        fqdn = "${infra.smtp.hostname}.${infra.smtp.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.smtp.id}";
        uri = "smtp://${infra.smtp.admin.fqdn}:${toString infra.port.smtp}";
        access.cidr = infra.cidr.admin;
      };
      user = {
        domain = infra.domain.user;
        namespace = infra.namespace.user;
        fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
        ip = "${infra.net.user}.${toString infra.smtp.id}";
        uri = "smtp://${infra.smtp.user.fqdn}:${toString infra.port.smtp}";
        access.cidr = infra.cidr.user;
      };
      external = {
        domain = infra.site.domain.extern;
        fqdn = "${infra.smtp.hostname}.${infra.smtp.external.domain}";
        ip = "192.168.21.125"; #
        uri = "smtp://${infra.smtp.external.ip}:${toString infra.port.smtp}";
        uriTcp = "tcp://${infra.smtp.external.ip}:${toString infra.port.smtp}";
        access.cidr = infra.cidr.user;
      };
    };
    # auto configure imap, jmap, smtp, thunderbird
    # https://www.ietf.org/archive/id/draft-ietf-mailmaint-autoconfig-00.html#name-formal-definition
    autoconfig = {
      id = 26;
      hostname = "autoconfig";
      localbind.port.http = infra.localhost.port.offset + infra.autoconfig.id;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.autoconfig.hostname}.${infra.autoconfig.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.autoconfig.id}";
        auth = {
          authentication = "password-cleartext"; # password-cleartext; none; other see doc
          id = "%EMAILADDRESS%"; #   %EMAILADDRESS% ;  %EMAILLOCALPART%
          socketType = "plain"; # SSL ; STARTTLS ; plain
        };
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.autoconfig.hostname}.${infra.autoconfig.user.domain}";
        ip = "${infra.net.user}.${toString infra.autoconfig.id}";
        auth = {
          authentication = "password-cleartext";
          id = "%EMAILADDRESS%";
          socketType = "plain";
        };
      };
      external = {
        domain = infra.email.domain.extern;
        fqdn = "${infra.autoconfig.hostname}.${infra.autoconfig.external.domain}";
        ip = "${infra.net.user}.${toString infra.autoconfig.id}";
        auth = {
          authentication = "password-cleartext";
          id = "%EMAILADDRESS%";
          socketType = "plain";
        };
      };
    };
    webmail = {
      id = 27;
      hostname = "webmail";
      domain = infra.domain.user;
      fqdn = "${infra.webmail.hostname}.${infra.webmail.domain}";
      ip = "${infra.net.user}.${toString infra.webmail.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webmail.id;
    };
    git = {
      id = 30;
      app = "forgejo";
      name = "git";
      hostname = infra.git.name;
      domain = infra.domain.user;
      fqdn = "${infra.git.hostname}.${infra.git.domain}";
      ip = "${infra.net.user}.${toString infra.git.id}";
      localbind.port.http = infra.localhost.port.offset + infra.git.id;
      url = "https://${infra.git.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.git.app}.png";
    };
    git-mirror = {
      id = 31;
      app = "cgit";
      name = "git-mirror";
      hostname = infra.git-mirror.name;
      domain = infra.domain.user;
      fqdn = "${infra.git-mirror.hostname}.${infra.git-mirror.domain}";
      ip = "${infra.net.user}.${toString infra.git.id}";
      localbind.port.http = infra.localhost.port.offset + infra.git-mirror.id;
      storage = "${infra.storage.cache}/${infra.git-mirror.name}";
      repos = [
        "nixos/nixpkgs#https://github.com/nixos/nixpkgs"
        "nix-community/home-manager#https://github.com/nix-community/home-manger"
        "nix-community/disko#https://github.com/nix-community/disko"
        "ryantm/agenix#https://github.com/ryantm/agenix"
        "paepckehh/nixos#https://github.com/paepckehh/nixos"
      ];
      url = "https://${infra.git-mirror.fqdn}";
      logo = "${infra.res.url}/icon/png/git.png";
    };
    dns = {
      id = 53;
      name = "dns";
      resolver = {
        admin = {
          primary = "${infra.net.admin}.${toString infra.dns.id}";
          secondary = "${infra.net.admin}.${toString infra.dns.id}";
        };
        user = {
          primary = "${infra.net.user}.${toString infra.dns.id}";
          secondary = "${infra.net.user}.${toString infra.dns.id}";
        };
      };
      hostname = infra.dns.name;
      domain = infra.domain.user;
      fqdn = "${infra.dns.hostname}.${infra.dns.domain}";
      port = infra.port.dns;
      ip = "${infra.net.user}.${toString infra.dns.id}";
      access = infra.cidr.all;
      accessArray = infra.cidr.allArray;
      upstream = ["192.168.80.1" "192.168.90.250" "192.168.100.250" "192.168.40.250" "10.20.6.2" "10.20.0.2"]; # XXX
      contact = "it.${infra.smtp.external.domain}";
    };
    adguard = {
      id = infra.dns.id;
      app = "adguard-home";
      name = "adguard";
      hostname = infra.adguard.name;
      domain = infra.domain.admin;
      fqdn = "${infra.adguard.hostname}.${infra.adguard.domain}";
      ip = "${infra.net.admin}.${toString infra.adguard.id}";
      localbind.port.http = infra.localhost.port.offset + infra.adguard.id;
      filter_lists = [
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        "https://easylist.to/easylist/easylist.txt"
        "https://easylist.to/easylistgermany/easylistgermany.txt"
        "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt"
        "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
      ];
      user_rules = [
        "@@||bahn.de^$important"
        "@@||config.teams.microsoft.com^$important"
        "@@||config.teams.trafficmanager.net^$important"
        "||use-application-dns.net" # switch firefox doh off
        "||skype.com"
        "||footprintdns.com"
        "||lenovo.com"
        "||lenovomm.com"
        "||chifsr.lenovomm.com"
        "||ads.mozilla.org"
        "||ipv6.msftncsi.com"
        "||ipv6.msftconnecttest.com"
        "||detectportal.firefox.com"
        "||telemetry.firefox.com"
        "||services.mozilla.com"
        "||teamviewer.com"
        "||adobe.com"
        "||adobe.io"
        "||mtalk.google.com"
        "||trace.svc.ui.com"
        "||ping.ui.com"
      ];
      upstream_dns = [
        "sdns://AQcAAAAAAAAADjIzLjE0MC4yNDguMTAwIFa3zBQNs5jjEISHskpY7WSNK4sLj_qrbFiLk5tSBN1uGTIuZG5zY3J5cHQtY2VydC5kbnNjcnkucHQ"
        "sdns://AQcAAAAAAAAADzE0Ny4xODkuMTQwLjEzNiCL7wgLXnE-35sDhXk5N1RNpUfWmM2aUBcMFlst7FPdnRkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
        "sdns://AQcAAAAAAAAADDIzLjE4NC40OC4xOSCwg3q2XK6z70eHJhi0H7whWQ_ZWQylhMItvqKpd9GtzRkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
        "sdns://AQcAAAAAAAAADzE3Ni4xMTEuMjE5LjEyNiDzuja5nmAyDvA5jakqkuLQEtb245xsAhNwJYDLkKraKhkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
      ];
      url = "https://${infra.adguard.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.adguard.app}.png";
    };
    cache = {
      id = 55;
      app = "ncps";
      name = "cache";
      hostname = infra.cache.name;
      domain = infra.domain.user;
      fqdn = "${infra.cache.hostname}.${infra.cache.domain}";
      ip = "${infra.net.user}.${toString infra.cache.id}";
      access.cidr = infra.cidr.all;
      localbind.port.http = infra.localhost.port.offset + infra.cache.id;
      url = "https://${infra.cache.fqdn}";
      processor = "cpu"; # cpu, rocm, cuda, vulcan
      size = "256G";
      storage = "${infra.storage.cache}/${infra.cache.app}";
      key = {
        url = "${infra.cache.url}/pubkey";
        pub = "cache:aFde6/c1Vz93N1XGGrvt/7NlUNdAyV35CgBUXKzyhyU=";
      };
    };
    it = {
      id = 56;
      name = "it";
      hostname = infra.it.name;
      domain = infra.domain.user;
      fqdn = "${infra.it.hostname}.${infra.it.domain}";
      ip = "${infra.net.user}.${toString infra.it.id}";
      localbind.port.http = infra.localhost.port.offset + infra.it.id;
    };
    proxmox = {
      id = 57;
      app = "proxmox";
      name = infra.proxmox.app;
      hostname = infra.proxmox.name;
      domain = infra.domain.admin;
      fqdn = "${infra.proxmox.hostname}.${infra.proxmox.domain}";
      ip = "${infra.net.admin}.${toString infra.proxmox.id}";
      localbind.port.http = infra.localhost.port.offset + infra.proxmox.id;
      url = "https://${infra.proxmox.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.proxmox.app}.png";
    };
    ldap = {
      id = 86;
      app = "lldap";
      name = "ldap";
      hostname = infra.ldap.name;
      domain = infra.domain.admin;
      fqdn = "${infra.ldap.hostname}.${infra.ldap.domain}";
      ip = "${infra.net.admin}.${toString infra.ldap.id}";
      port = infra.port.ldap;
      url = "http://${infra.ldap.ip}:${toString infra.ldap.port}";
      uri = "ldap://${infra.ldap.ip}:${toString infra.ldap.port}";
      uriHost = "ldap://${infra.ldap.ip}";
      base = "dc=${infra.zonename.user},dc=${infra.domain.tld}";
      baseDN = "ou=people,${infra.ldap.base}";
      bind = {
        dn = "uid=bind,${infra.ldap.baseDN}";
        pwd = "startbind"; # public bind
      };
    };
    iam = {
      id = infra.ldap.id;
      app = "lldap";
      name = "iam";
      hostname = infra.iam.name;
      domain = infra.domain.user;
      fqdn = "${infra.iam.hostname}.${infra.iam.domain}";
      ip = "${infra.net.user}.${toString infra.iam.id}";
      ports = infra.port.webapps;
      access.cidr = infra.cidr.all;
      localbind.port.http = infra.localhost.port.offset + infra.iam.id;
      url = "https://${infra.iam.fqdn}";
      logo = "${infra.res.url}/icon/png/nextcloud-contacts.png";
    };
    sso = {
      id = 87;
      app = "authelia";
      app2 = "Authelia";
      name = "sso";
      hostname = infra.sso.name;
      site = infra.site.name;
      domain = infra.domain.user;
      fqdn = "${infra.sso.hostname}.${infra.sso.domain}";
      ip = "${infra.net.user}.${toString infra.sso.id}";
      localbind.port.http = infra.localhost.port.offset + infra.sso.id;
      url = "https://${infra.sso.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.sso.app}.png";
      oidc = {
        auth = {
          basic = "client_secret_basic"; # paperless, openweb-ui, miniflux
          post = "client_secret_post"; # nextcloud
        };
        grant = "authorization_code";
        policy = "two_factor";
        method = "S256";
        response.code = "code";
        secret = "insecure_secret";
        hash = "$pbkdf2-sha512$310000$c8p78n7pUMln0jzvd4aK4Q$JNRBzwAo0ek5qKn50cFzzvE9RXV88h1wJn5KGiHrD0YKtZaR/nCb2CJPOsKaPK0hjf.9yHxzQGZziziccp6Yng";
        scope = "openid profile groups email";
        scopes = ["openid" "profile" "groups" "email"];
        discoveryUri = "${infra.sso.url}/.well-known/openid-configuration";
        consent = "implicit";
      };
    };
    srv = {
      id = 100;
      app = "nixos";
      name = "srv";
      hostname = infra.srv.name;
      sshd = false;
      reverseproxy = true;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.srv.hostname}.${infra.srv.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.srv.id}";
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.srv.hostname}.${infra.srv.user.domain}";
        ip = "${infra.net.user}.${toString infra.srv.id}";
      };
      remote = {
        domain = infra.domain.remote;
        fqdn = "${infra.srv.hostname}.${infra.srv.remote.domain}";
        ip = "192.168.80.100";
      };
      virtual = {
        domain = infra.domain.virtual;
        fqdn = "${infra.srv.hostname}.${infra.srv.virtual.domain}";
        ip = "${infra.net.user}.${toString infra.srv.id}";
      };
    };
    srv2 = {
      id = 102;
      app = "nixos";
      name = "srv2";
      hostname = infra.srv2.name;
      sshd = true;
      reverseproxy = false;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.srv2.hostname}.${infra.srv2.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.srv2.id}";
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.srv2.hostname}.${infra.srv2.user.domain}";
        ip = "${infra.net.user}.${toString infra.srv2.id}";
      };
      remote = {
        domain = infra.domain.remote;
        fqdn = "${infra.srv2.hostname}.${infra.srv2.remote.domain}";
        ip = "192.168.80.102";
      };
      virtual = {
        domain = infra.domain.virtual;
        fqdn = "${infra.srv2.hostname}.${infra.srv.virtual.domain}";
        ip = "${infra.net.user}.${toString infra.srv2.id}";
      };
    };
    syslog = {
      id = infra.srv.id;
      app = "syslog-ng";
      name = "syslog";
      hostname = infra.syslog.name;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.syslog.id}";
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.user.domain}";
        ip = "${infra.net.user}.${toString infra.syslog.id}";
      };
      remote = {
        domain = infra.domain.remote;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.remote.domain}";
        ip = "192.168.80.100";
      };
      virtual = {
        domain = infra.domain.virtual;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.virtual.domain}";
        ip = "${infra.net.virtual}.${toString infra.syslog.id}";
      };
    };
    pki = {
      id = 108;
      name = "pki";
      hostname = infra.pki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      ip = "${infra.net.admin}.${toString infra.pki.id}";
      url = "https://${infra.pki.fqdn}";
      certs = {
        defaultTLSCertDuration = "1440h0m0s";
        rootCA = {
          content = ''
            ### X509 CERT
          '';
          name = "rootCA.crt";
          path = "/etc/${infra.pki.certs.rootCA.name}";
        };
      };
      acme = {
        contact = infra.admin.email;
        url = "https://${infra.pki.fqdn}/acme/acme/directory";
      };
    };
    ai = {
      id = 109;
      app = "open-webui";
      name = "ai";
      hostname = infra.ai.name;
      domain = infra.domain.user;
      fqdn = "${infra.ai.hostname}.${infra.ai.domain}";
      ip = "${infra.net.user}.${toString infra.ai.id}";
      worker.one = "http://127.0.0.1:11434";
      worker.two = "http://aiworker01.${infra.domain.user}:11434";
      localbind = {
        proto = infra.localhost.proto;
        port.http = infra.localhost.port.offset + infra.ai.id;
      };
      url = "https://${infra.ai.fqdn}";
      logo = "${infra.res.url}/icon/png/ollama.png";
    };
    status = {
      id = 110;
      app = "status";
      name = "status";
      hostname = infra.status.name;
      domain = infra.domain.user;
      fqdn = "${infra.status.hostname}.${infra.status.domain}";
      ip = "${infra.net.user}.${toString infra.status.id}";
      localbind.port.http = infra.localhost.port.offset + infra.status.id;
      url = "https://${infra.status.fqdn}";
      logo = "${infra.res.url}/icon/png/healthchecks.png";
    };
    kuma = {
      id = 111;
      app = "uptimekuma";
      name = "kuma";
      hostname = infra.kuma.name;
      domain = infra.domain.user;
      fqdn = "${infra.kuma.hostname}.${infra.kuma.domain}";
      ip = "${infra.net.user}.${toString infra.kuma.id}";
      localbind.port.http = infra.localhost.port.offset + infra.kuma.id;
      url = "https://${infra.kuma.fqdn}";
      logo = "${infra.res.url}/icon/png/healthchecks.png";
    };
    wiki = {
      id = 112;
      app = "mediawiki";
      name = "wiki";
      hostname = infra.wiki.name;
      domain = infra.domain.user;
      fqdn = "${infra.wiki.hostname}.${infra.wiki.domain}";
      ip = "${infra.net.user}.${toString infra.wiki.id}";
      localbind.port.http = infra.localhost.port.offset + infra.wiki.id;
      url = "https://${infra.wiki.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.wiki.app}.png";
    };
    prometheus = {
      id = 113;
      app = "prometheus";
      app2 = "Prometheus";
      name = infra.prometheus.app;
      hostname = infra.prometheus.name;
      domain = infra.domain.admin;
      fqdn = "${infra.prometheus.hostname}.${infra.prometheus.domain}";
      ip = "${infra.net.admin}.${toString infra.prometheus.id}";
      url = "https://${infra.prometheus.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.prometheus.app}.png";
      localbind.port = {
        http = infra.localhost.port.offset + infra.prometheus.id;
        alertmananger = infra.localhost.port.offsetMetric + infra.prometheus.id;
      };
      storage = "${infra.storage.cache}/${infra.prometheus.app}";
      db.retenetion = "365d";
      exporter = {
        node = {
          port = 9100;
          targets = [
            "localhost:9100"
          ];
        };
        smartctl = {
          port = 9101;
          devices = ["/dev/nvme0"];
          targets = [
            "localhost:9101"
          ];
        };
      };
    };
    grafana = {
      id = 114;
      app = "grafana";
      name = infra.grafana.app;
      hostname = infra.grafana.name;
      domain = infra.domain.user;
      fqdn = "${infra.grafana.hostname}.${infra.grafana.domain}";
      ip = "${infra.net.user}.${toString infra.grafana.id}";
      localbind.port.http = infra.localhost.port.offset + infra.grafana.id;
      url = "https://${infra.grafana.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.grafana.app}.png";
    };
    opnborg = {
      id = 115;
      name = "opnborg";
      hostname = infra.opnborg.name;
      domain = infra.domain.admin;
      fqdn = "${infra.opnborg.hostname}.${infra.opnborg.domain}";
      ip = "${infra.net.admin}.${toString infra.opnborg.id}";
      access.cidr = infra.cidr.admin;
      localbind.port.http = infra.localhost.port.offset + infra.opnborg.id;
      url = "https://${infra.opnborg.fqdn}";
      logo = "${infra.res.url}/icon/png/borgmatic.png";
    };
    nextcloud = {
      id = 117;
      app = "nextcloud";
      name = "nextcloud";
      hostname = infra.nextcloud.name;
      domain = infra.domain.user;
      fqdn = "${infra.nextcloud.hostname}.${infra.nextcloud.domain}";
      ip = "${infra.net.user}.${toString infra.nextcloud.id}";
      port = infra.port.webapps;
      localbind.port.http = infra.localhost.port.offset + infra.nextcloud.id;
      url = "https://${infra.nextcloud.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.nextcloud.name}-blue.png";
    };
    wpad = {
      id = 118;
      name = "wpad";
      hostname = infra.wpad.name;
      domain = infra.domain.user;
      fqdn = "${infra.wpad.hostname}.${infra.wpad.domain}";
      ip = "${infra.net.user}.${toString infra.wpad.id}";
      access.cidr = infra.cidr.user;
      logo = "${infra.res.url}/icon/png/haproxy.png";
      url = "https://${infra.wpad.fqdn}";
      content = ''
        header Content-Type application/x-ns-proxy-autoconfig
        respond <<HTML
        function FindProxyForURL(url, host) {
        url = url.toLowerCase();
        host = host.toLowerCase();
        /* Debitor internal IT  */
        if (shExpMatch(host, "127.0.0.1" ))                    {return "DIRECT";}
        if (shExpMatch(host, "*/localhost*" ))                 {return "DIRECT";}
        if (dnsDomainIs(host,".corp"))                         {return "DIRECT";}
        /* Windows Update Dumpster */
        if (dnsDomainIs(host,".msn.com"))                      {return "PROXY 10.20.6.12:3128";}
        if (dnsDomainIs(host,".windows.com"))                  {return "PROXY 10.20.6.12:3128";}
        if (dnsDomainIs(host,".windowsupdate.com"))            {return "PROXY 10.20.6.12:3128";}
        return 'PROXY ${infra.proxy.one.uri}; PROXY ${infra.proxy.two.uri}; PROXY ${infra.proxy.three.uri}; DIRECT';
        }
        HTML 200
      '';
    };
    search = {
      id = 119;
      app = "searxng";
      label = "searX";
      name = "search";
      hostname = infra.search.name;
      domain = infra.domain.user;
      fqdn = "${infra.search.hostname}.${infra.search.domain}";
      ip = "${infra.net.user}.${toString infra.search.id}";
      port = infra.port.webapps;
      localbind.port.http = infra.localhost.port.offset + infra.search.id;
      query.url = "${infra.search.url}/search?q=<query>";
      urls = {
        search = "${infra.search.url}/search?q={searchTerms}";
        suggest = "${infra.search.url}/autocompleter?q={searchTerms}";
      };
      url = "https://${infra.search.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.search.app}.png";
    };
    ops2.id = 120;
    ops3.id = 121;
    vault = {
      id = 124;
      app = "vaultwarden";
      name = "vault";
      hostname = infra.vault.name;
      domain = infra.domain.user;
      fqdn = "${infra.vault.hostname}.${infra.vault.domain}";
      ip = "${infra.net.user}.${toString infra.vault.id}";
      localbind.port.http = infra.localhost.port.offset + infra.vault.id;
      url = "https://${infra.vault.fqdn}";
      logo = "${infra.res.url}/icon/png/bitwarden.png";
    };
    paperless = {
      id = 125;
      app = "paperless";
      name = infra.paperless.app;
      hostname = infra.paperless.name;
      domain = infra.domain.user;
      fqdn = "${infra.paperless.hostname}.${infra.paperless.domain}";
      ip = "${infra.net.user}.${toString infra.paperless.id}";
      localbind.port.http = infra.localhost.port.offset + infra.paperless.id;
      url = "https://${infra.paperless.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.paperless.name}.png";
    };
    ops4.id = 126;
    matrix = {
      id = 127;
      app = "tuwunel";
      name = "matrix";
      ldap = false;
      self-register = {
        enable = true;
        password = "start";
      };
      externalHostname = "matrix.${infra.site.external.domain}";
      hostname = infra.matrix.name;
      domain = infra.domain.user;
      fqdn = "${infra.matrix.hostname}.${infra.matrix.domain}";
      ip = "${infra.net.user}.${toString infra.matrix.id}";
      access.cidr = "${infra.cidr.user}";
      localbind.port.http = infra.localhost.port.offset + infra.matrix.id;
      url = "https://${infra.matrix.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.matrix.app}.png";
    };
    matrix-web = {
      id = 128;
      app = "element";
      name = "matrix-web";
      hostname = infra.matrix-web.name;
      domain = infra.domain.user;
      fqdn = "${infra.matrix-web.hostname}.${infra.matrix-web.domain}";
      ip = "${infra.net.user}.${toString infra.matrix-web.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.matrix-web.id;
      url = "https://${infra.matrix-web.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.matrix-web.app}.png";
    };
    ops5.id = 129;
    webarchiv = {
      id = 130;
      app = "readeck";
      name = "webarchiv";
      hostname = infra.webarchiv.name;
      domain = infra.domain.user;
      fqdn = "${infra.webarchiv.hostname}.${infra.webarchiv.domain}";
      ip = "${infra.net.user}.${toString infra.webarchiv.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webarchiv.id;
      url = "https://${infra.webarchiv.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.webarchiv.app}.png";
    };

    portal = {
      id = 135;
      app = "homer";
      name = "start";
      hostname = infra.portal.name;
      domain = infra.domain.user;
      fqdn = "${infra.portal.hostname}.${infra.portal.domain}";
      ip = "${infra.net.user}.${toString infra.portal.id}";
      localbind.port.http = infra.localhost.port.offset + infra.portal.id;
      url = "https://${infra.portal.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.portal.app}.png";
    };
    res = {
      id = 141;
      app = "caddy";
      name = "res";
      hostname = infra.res.name;
      domain = infra.domain.user;
      fqdn = "${infra.res.hostname}.${infra.res.domain}";
      ip = "${infra.net.user}.${toString infra.res.id}";
      www.root = "/var/lib/caddy/res";
      url = "https://${infra.res.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.res.app}.png";
    };
    imap = {
      id = 143;
      hostname = "imap";
      admin = {
        domain = infra.domain.user;
        fqdn = "${infra.imap.hostname}.${infra.imap.admin.domain}";
        ip = "${infra.net.user}.${toString infra.imap.id}";
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.imap.hostname}.${infra.imap.user.domain}";
        ip = "${infra.net.user}.${toString infra.imap.id}";
      };
    };
    webacme = {
      id = 151;
      app = "cert-warden";
      name = "webacme";
      hostname = infra.webacme.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webacme.hostname}.${infra.webacme.domain}";
      ip = "${infra.net.admin}.${toString infra.webacme.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webacme.id;
      url = "https://${infra.webacme.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.webacme.app}.png";
    };
    webpki = {
      id = 152;
      app = "mkcert-web";
      name = "webpki";
      hostname = infra.webpki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webpki.hostname}.${infra.webpki.domain}";
      ip = "${infra.net.admin}.${toString infra.webpki.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webpki.id;
      url = "https://${infra.webpki.fqdn}";
      logo = "${infra.res.url}/icon/png/cert-manager.png";
    };
    vaultls = {
      id = 153;
      app = "vaultls";
      name = infra.vaultls.app;
      hostname = infra.vaultls.name;
      domain = infra.domain.user;
      namespace = infra.namespace.user;
      fqdn = "${infra.vaultls.hostname}.${infra.vaultls.domain}";
      ip = "${infra.net.user}.${toString infra.vaultls.id}";
      localbind.port.http = infra.localhost.port.offset + infra.vaultls.id;
      api = "a2Ni8SCUuCboDfAa5VGZ8ByPxb2k6hM//babfp/2F+A=";
      db = "9ME/zzODKjHOMKmUYhSccHFxZ5Q+sWqJrCCu+yfalIs=";
      oidc = {
        secret = "insecure_secret";
        callback.url = "${infra.vaultls.url}/api/auth/oidc/callback";
      };
      url = "https://${infra.vaultls.fqdn}";
      logo = "${infra.res.url}/icon/png/vault.png";
    };
    translate = {
      id = 154;
      app = "libretranslate";
      name = "translate";
      hostname = infra.translate.name;
      domain = infra.domain.user;
      fqdn = "${infra.translate.hostname}.${infra.translate.domain}";
      ip = "${infra.net.user}.${toString infra.translate.id}";
      localbind.port.http = infra.localhost.port.offset + infra.translate.id;
      container.ip = "${infra.net.container}.${toString infra.translate.id}";
      logo = "${infra.res.url}/icon/png/${infra.translate.app}.png";
      url = "https://${infra.translate.fqdn}";
    };
    test = {
      id = 155;
      app = "test";
      name = "test";
      hostname = infra.test.name;
      domain = infra.domain.user;
      fqdn = "${infra.test.hostname}.${infra.test.domain}";
      ip = "${infra.net.user}.${toString infra.test.id}";
      url = "https://${infra.test.fqdn}";
      logo = "${infra.res.url}/icon/png/caddy.png";
    };
    grist = {
      id = 156;
      app = "grist";
      name = infra.grist.app;
      hostname = infra.grist.name;
      domain = infra.domain.user;
      fqdn = "${infra.grist.hostname}.${infra.grist.domain}";
      ip = "${infra.net.user}.${toString infra.grist.id}";
      localbind.port.http = infra.localhost.port.offset + infra.grist.id;
      url = "https://${infra.grist.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.grist.app}.png";
    };
    meshtastic-web = {
      id = 157;
      app = "meshtastic";
      name = "${infra.meshtastic-web.app}-web";
      hostname = infra.meshtastic-web.name;
      domain = infra.domain.user;
      fqdn = "${infra.meshtastic-web.hostname}.${infra.meshtastic-web.domain}";
      ip = "${infra.net.user}.${toString infra.meshtastic-web.id}";
      localbind.port.http = infra.localhost.port.offset + infra.meshtastic-web.id;
      url = "https://${infra.meshtastic-web.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.meshtastic-web.app}.png";
    };
    glance = {
      id = 158;
      app = "glance";
      name = infra.glance.app;
      hostname = infra.glance.name;
      domain = infra.domain.user;
      fqdn = "${infra.glance.hostname}.${infra.glance.domain}";
      ip = "${infra.net.user}.${toString infra.glance.id}";
      localbind.port.http = infra.localhost.port.offset + infra.glance.id;
      url = "https://${infra.glance.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.glance.app}.png";
    };
    immich = {
      id = 159;
      app = "immich";
      name = infra.immich.app;
      hostname = infra.immich.name;
      domain = infra.domain.user;
      fqdn = "${infra.immich.hostname}.${infra.immich.domain}";
      ip = "${infra.net.user}.${toString infra.immich.id}";
      container.ip = "${infra.net.container}.${toString infra.immich.id}";
      localbind.port.http = infra.localhost.port.offset + infra.immich.id;
      url = "https://${infra.immich.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.immich.app}.png";
    };
    ente = {
      id = 160;
      app = "ente";
      name = infra.ente.app;
      hostname = infra.ente.name;
      domain = infra.domain.user;
      fqdn = "${infra.ente.hostname}.${infra.ente.domain}";
      ip = "${infra.net.user}.${toString infra.ente.id}";
      localbind.port.http = infra.localhost.port.offset + infra.ente.id;
      url = "https://${infra.ente.fqdn}";
      logo = "${infra.res.url}/icon/png/ente-photos.png";
    };
    miniflux = {
      id = 161;
      app = "miniflux";
      name = infra.miniflux.app;
      hostname = infra.miniflux.name;
      domain = infra.domain.user;
      fqdn = "${infra.miniflux.hostname}.${infra.miniflux.domain}";
      ip = "${infra.net.user}.${toString infra.miniflux.id}";
      localbind.port.http = infra.localhost.port.offset + infra.miniflux.id;
      url = "https://${infra.miniflux.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.miniflux.app}.png";
    };
    navidrome = {
      id = 162;
      app = "navidrome";
      name = infra.navidrome.app;
      hostname = infra.navidrome.name;
      domain = infra.domain.user;
      fqdn = "${infra.navidrome.hostname}.${infra.navidrome.domain}";
      ip = "${infra.net.user}.${toString infra.navidrome.id}";
      localbind.port.http = infra.localhost.port.offset + infra.navidrome.id;
      url = "https://${infra.navidrome.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.navidrome.app}.png";
    };
    chef = {
      id = 163;
      app = "chef";
      name = infra.chef.app;
      hostname = infra.chef.name;
      domain = infra.domain.user;
      fqdn = "${infra.chef.hostname}.${infra.chef.domain}";
      ip = "${infra.net.user}.${toString infra.chef.id}";
      localbind.port.http = infra.localhost.port.offset + infra.chef.id;
      url = "https://${infra.chef.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.chef.app}.png";
    };
    onlyoffice = {
      id = 164;
      app = "onlyoffice";
      name = infra.onlyoffice.app;
      hostname = infra.onlyoffice.name;
      domain = infra.domain.user;
      fqdn = "${infra.onlyoffice.hostname}.${infra.onlyoffice.domain}";
      ip = "${infra.net.user}.${toString infra.onlyoffice.id}";
      localbind.port.http = infra.localhost.port.offset + infra.onlyoffice.id;
      container.ip = "${infra.net.container}.${toString infra.onlyoffice.id}";
      url = "https://${infra.onlyoffice.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.onlyoffice.app}.png";
    };
    ollama01 = {
      id = 165;
      app = "ollama01";
      name = infra.ollama01.app;
      hostname = infra.ollama01.name;
      domain = infra.domain.admin;
      fqdn = "${infra.ollama01.hostname}.${infra.ollama01.domain}";
      ip = "${infra.net.user}.${toString infra.ollama01.id}";
      storage = "${infra.storage.cache}/ollama/models";
      models = [];
      localbind.port.http = infra.localhost.port.offset + infra.ollama01.id;
    };
    rackula = {
      id = 170;
      app = "rackula";
      name = infra.rackula.app;
      hostname = infra.rackula.name;
      domain = infra.domain.admin;
      fqdn = "${infra.rackula.hostname}.${infra.rackula.domain}";
      ip = "${infra.net.user}.${toString infra.rackula.id}";
      localbind.port.http = infra.localhost.port.offset + infra.rackula.id;
      url = "https://${infra.rackula.fqdn}";
      logo = "${infra.res.url}/icon/png/mcmyadmin.png";
    };
    bentopdf = {
      id = 171;
      app = "bentopdf";
      name = infra.bentopdf.app;
      hostname = infra.bentopdf.name;
      domain = infra.domain.user;
      fqdn = "${infra.bentopdf.hostname}.${infra.bentopdf.domain}";
      ip = "${infra.net.user}.${toString infra.bentopdf.id}";
      localbind.port.http = infra.localhost.port.offset + infra.bentopdf.id;
      url = "https://${infra.bentopdf.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.bentopdf.app}.png";
    };
    web-check = {
      id = 172;
      app = "web-check";
      name = infra.web-check.app;
      hostname = infra.web-check.name;
      domain = infra.domain.user;
      fqdn = "${infra.web-check.hostname}.${infra.web-check.domain}";
      ip = "${infra.net.user}.${toString infra.web-check.id}";
      localbind.port.http = infra.localhost.port.offset + infra.web-check.id;
      url = "https://${infra.web-check.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.web-check.app}.png";
    };
    databasement = {
      id = 173;
      app = "databasement";
      name = infra.databasement.app;
      hostname = infra.databasement.name;
      domain = infra.domain.admin;
      fqdn = "${infra.databasement.hostname}.${infra.databasement.domain}";
      ip = "${infra.net.admin}.${toString infra.databasement.id}";
      localbind.port.http = infra.localhost.port.offset + infra.databasement.id;
      url = "https://${infra.databasement.fqdn}";
      logo = "${infra.res.url}/icon/png/webdb.png";
    };
    jellyfin = {
      id = 174;
      app = "jellyfin";
      name = infra.jellyfin.app;
      hostname = infra.jellyfin.name;
      domain = infra.domain.user;
      fqdn = "${infra.jellyfin.hostname}.${infra.jellyfin.domain}";
      ip = "${infra.net.user}.${toString infra.jellyfin.id}";
      localbind.port.http = infra.localhost.port.offset + infra.jellyfin.id;
      url = "https://${infra.jellyfin.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.jellyfin.app}.png";
    };
    kimai = {
      id = 175;
      app = "kimai";
      name = infra.kimai.app;
      hostname = infra.kimai.name;
      domain = infra.domain.user;
      fqdn = "${infra.kimai.hostname}.${infra.kimai.domain}";
      ip = "${infra.net.user}.${toString infra.kimai.id}";
      localbind.port.http = infra.localhost.port.offset + infra.kimai.id;
      url = "https://${infra.kimai.fqdn}";
      logo = "${infra.res.url}/icon/png/nextcloud-timemanager.png";
    };
    erpnext = {
      id = 176;
      app = "erpnext";
      name = infra.erpnext.app;
      hostname = infra.erpnext.name;
      domain = infra.domain.user;
      fqdn = "${infra.erpnext.hostname}.${infra.erpnext.domain}";
      ip = "${infra.net.user}.${toString infra.erpnext.id}";
      localbind.port.http = infra.localhost.port.offset + infra.erpnext.id;
      url = "https://${infra.erpnext.fqdn}";
      logo = "${infra.res.url}/icon/png/espocrm.png";
    };
    networking-toolbox = {
      id = 176;
      app = "networking-toolbox";
      name = infra.networking-toolbox.app;
      hostname = infra.networking-toolbox.name;
      domain = infra.domain.user;
      fqdn = "${infra.networking-toolbox.hostname}.${infra.networking-toolbox.domain}";
      ip = "${infra.net.user}.${toString infra.networking-toolbox.id}";
      localbind.port.http = infra.localhost.port.offset + infra.networking-toolbox.id;
      url = "https://${infra.networking-toolbox.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.networking-toolbox.app}.png";
    };
    wiki-go = {
      id = 177;
      app = "wiki-go";
      name = infra.wiki-go.app;
      hostname = infra.wiki-go.name;
      domain = infra.domain.user;
      fqdn = "${infra.wiki-go.hostname}.${infra.wiki-go.domain}";
      ip = "${infra.net.user}.${toString infra.wiki-go.id}";
      localbind.port.http = infra.localhost.port.offset + infra.wiki-go.id;
      url = "https://${infra.wiki-go.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.wiki-go.name}.png";
    };
    coturn = {
      id = 178;
      app = "coturn";
      name = infra.coturn.app;
      hostname = infra.coturn.name;
      domain = infra.domain.user;
      fqdn = "${infra.coturn.hostname}.${infra.coturn.domain}";
      ip = "${infra.net.user}.${toString infra.coturn.id}";
      localbind.port.http = infra.localhost.port.offset + infra.coturn.id;
      url = "https://${infra.coturn.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.coturn.name}.png";
    };
    websurfx = {
      id = 179;
      app = "websurfx";
      name = infra.websurfx.app;
      hostname = infra.websurfx.name;
      domain = infra.domain.user;
      fqdn = "${infra.websurfx.hostname}.${infra.websurfx.domain}";
      ip = "${infra.net.user}.${toString infra.websurfx.id}";
      localbind.port.http = infra.localhost.port.offset + infra.websurfx.id;
      url = "https://${infra.websurfx.fqdn}";
      logo = "${infra.res.url}/icon/png/searxng.png";
    };
    timetrack = {
      id = 180;
      app = "timetrack";
      name = infra.timetrack.app;
      hostname = infra.timetrack.name;
      domain = infra.domain.user;
      fqdn = "${infra.timetrack.hostname}.${infra.timetrack.domain}";
      ip = "${infra.net.user}.${toString infra.timetrack.id}";
      localbind.port.http = infra.localhost.port.offset + infra.timetrack.id;
      url = "https://${infra.timetrack.fqdn}";
      logo = "${infra.res.url}/icon/png/nextcloud-timemanager.png";
    };
    donetick = {
      id = 181;
      app = "donetick";
      name = infra.donetick.app;
      hostname = infra.donetick.name;
      domain = infra.domain.user;
      fqdn = "${infra.donetick.hostname}.${infra.donetick.domain}";
      ip = "${infra.net.user}.${toString infra.donetick.id}";
      localbind.port.http = infra.localhost.port.offset + infra.donetick.id;
      url = "https://${infra.donetick.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.donetick.app}.png";
    };
    zipline = {
      id = 182;
      app = "zipline";
      name = infra.zipline.app;
      hostname = infra.zipline.name;
      domain = infra.domain.user;
      fqdn = "${infra.zipline.hostname}.${infra.zipline.domain}";
      ip = "${infra.net.user}.${toString infra.zipline.id}";
      localbind.port.http = infra.localhost.port.offset + infra.zipline.id;
      url = "https://${infra.zipline.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.zipline.app}.png";
    };
    dumbdrop = {
      id = 183;
      app = "dumbdrop";
      name = infra.dumbdrop.app;
      hostname = infra.dumbdrop.name;
      domain = infra.domain.user;
      fqdn = "${infra.dumbdrop.hostname}.${infra.dumbdrop.domain}";
      ip = "${infra.net.user}.${toString infra.dumbdrop.id}";
      localbind.port.http = infra.localhost.port.offset + infra.dumbdrop.id;
      url = "https://${infra.dumbdrop.fqdn}";
      logo = "${infra.res.url}/icon/png/dropbox.png";
    };
    undb = {
      id = 184;
      app = "undb";
      name = infra.undb.app;
      hostname = infra.undb.name;
      domain = infra.domain.user;
      fqdn = "${infra.undb.hostname}.${infra.undb.domain}";
      ip = "${infra.net.user}.${toString infra.undb.id}";
      localbind.port.http = infra.localhost.port.offset + infra.undb.id;
      url = "https://${infra.undb.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.undb.app}.png";
    };
    vikunja = {
      id = 185;
      app = "vikunja";
      name = infra.vikunja.app;
      hostname = infra.vikunja.name;
      domain = infra.domain.user;
      fqdn = "${infra.vikunja.hostname}.${infra.vikunja.domain}";
      ip = "${infra.net.user}.${toString infra.vikunja.id}";
      localbind.port.http = infra.localhost.port.offset + infra.vikunja.id;
      url = "https://${infra.vikunja.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.vikunja.app}.png";
    };
    bichon = {
      id = 186;
      app = "bichon";
      name = infra.bichon.app;
      hostname = infra.bichon.name;
      domain = infra.domain.user;
      fqdn = "${infra.bichon.hostname}.${infra.bichon.domain}";
      ip = "${infra.net.user}.${toString infra.bichon.id}";
      localbind.port.http = infra.localhost.port.offset + infra.bichon.id;
      url = "https://${infra.bichon.fqdn}";
      logo = "${infra.res.url}/icon/png/twake-mail.png";
    };
  };
in {infra = infra;}
