{
  config,
  pkgs,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    consoleLogLevel = 4;
    blacklistedKernelModules = ["affs" "befs" "bfs" "freevxfs" "hpfs" "jfs" "minix" "nilfs2" "omfs" "qnx4" "qnx6" "k10temp" "ssb"];
    nixStoreMountOpts = lib.mkForce ["ro"];
    hardwareScan = true;
    extraModulePackages = (
      if (config.nixpkgs.system == "x86_64-linux")
      then [config.boot.kernelPackages.zenpower]
      else []
    );
    initrd = {
      compressor = "zstd";
      compressorArgs = ["--ultra" "--long" "-22"];
      systemd = {
        enable = lib.mkForce true;
        emergencyAccess = lib.mkForce true;
      };
      luks.mitigateDMAAttacks = lib.mkForce true;
      supportedFilesystems = ["ext4" "tmpfs"];
      availableKernelModules = (
        if (config.nixpkgs.system == "x86_64-linux")
        then ["aesni_intel" "ahci" "applespi" "applesmc" "dm_mod" "cryptd" "intel_lpss_pci" "nvme" "thunderbolt" "sd_mod" "uas" "usbhid" "usb_storage" "xhci_pci"]
        else ["ahci" "dm_mod" "cryptd" "nvme" "thunderbolt" "sd_mod" "uas" "usbhid" "usb_storage" "xhci_pci"]
      );
    };
    kernelPackages = (
      if (config.system.nixos.release == "25.11")
      then pkgs.linuxPackages_latest
      else pkgs.linuxPackages
    );
    kernelParams = (
      if (config.nixpkgs.system == "x86_64-linux")
      then ["amd_pstate=active" "page_alloc.shuffle=1" "ipv6.disable=1"] # "copytoram"
      else ["page_alloc.shuffle=1" "ipv6.disable=1"]
    );
    kernelModules = (
      if (config.nixpkgs.system == "x86_64-linux")
      then ["amd-pstate" "amdgpu" "exfat" "kvm-amd" "kvm-intel" "uas" "vfat"]
      else ["exfat" "uas" "vfat"]
    );
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
      tmpfsHugeMemoryPages = "within_size";
      tmpfsSize = "85%";
      useZram = false; # toggle only on memory constrained systems
      zramSettings = {
        compression-algorithm = "zstd";
        fs-type = "ext4";
        zram-size = "ram * 0.85";
      };
    };
    runSize = "85%";
    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 4;
      };
    };
    kernel.sysctl = lib.mkDefault {
      "kernel.kptr_restrict" = 2;
      "kernel.ftrace_enabled" = 0;
      "net.core.rmem_max" = lib.mkForce 7500000;
      "net.core.wmem_max" = lib.mkForce 7500000;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv6.conf.all.disable_ipv6" = 1;
      "net.ipv6.conf.eth0.disable_ipv6" = 1;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.disable_ipv6" = 1;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "vm.overcommit_memory" = 1;
    };
  };

  ###############
  #-= SYSTEM #=-#
  ###############
  system = {
    stateVersion = "25.11"; # dummy target, do not modify
    switch.enable = true;
    rebuild.enableNg = true;
    includeBuildDependencies = false; # needed for full-offline (re-)build from source, its huge!
  };
  time = {
    timeZone = null; # UTC, local: "Europe/Berlin";
    hardwareClockInLocalTime = true;
  };
  console = {
    enable = lib.mkForce true;
    earlySetup = lib.mkForce true;
    keyMap = "us";
    font = "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v18b.psf.gz";
    packages = with pkgs; [powerline-fonts];
  };
  swapDevices = lib.mkForce [];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    priority = 5;
  };

  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs = {
    config = {
      allowBroken = lib.mkDefault true; # XXX dev mode
      allowUnfree = lib.mkDefault true;
    };
  };

  #############
  #-=# NIX #=-#
  #############
  nix = {
    enable = true;
    daemonCPUSchedPolicy = "idle";
    extraOptions = ''
      builders-use-substitutes = false
      experimental-features = nix-command flakes'';
    settings = {
      auto-optimise-store = true;
      allowed-users = lib.mkForce ["@wheel"];
      trusted-users = lib.mkForce ["@wheel"];
      http2 = lib.mkForce false;
      sandbox = lib.mkForce true;
      sandbox-build-dir = "/build";
      sandbox-fallback = lib.mkForce false;
      trace-verbose = true;
      restrict-eval = lib.mkForce false;
      require-sigs = lib.mkForce true;
      preallocate-contents = true;
      allowed-uris = [
        # "https://nixpkgs-unfree.cachix.org"
        # "https://nix-community.cachix.org"
        # "https://cache.saumon.network/proxmox-nixos"
        "https://cache.nixos.org"
      ];
      substituters = [
        # "https://nixpkgs-unfree.cachix.org"
        # "https://nix-community.cachix.org"
        # "https://cache.saumon.network/proxmox-nixos"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        # "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      persistent = true;
      options = "--delete-older-than 42d";
    };
    optimise = {
      automatic = true;
      dates = ["daily"];
    };
  };

  #######################
  #-=# DOCUMENTATION #=-#
  #######################
  documentation = {
    doc.enable = lib.mkForce false;
    dev.enable = lib.mkForce false;
    info.enable = lib.mkForce false;
    nixos.enable = lib.mkForce false;
    man = {
      enable = lib.mkForce true;
      generateCaches = lib.mkForce false;
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    acpilight.enable = true;
    amdgpu = {
      amdvlk.enable = true;
      opencl.enable = false;
    };
    enableAllFirmware = lib.mkForce true;
    enableAllHardware = lib.mkForce true;
    enableRedistributableFirmware = lib.mkForce true;
    cpu = {
      amd = {
        updateMicrocode = true;
        ryzen-smu.enable = true;
        sev.enable = lib.mkForce false;
      };
      intel = {
        updateMicrocode = true;
        sgx.provision.enable = lib.mkForce false;
      };
    };
    i2c.enable = true;
    intel-gpu-tools.enable = true;
    uinput.enable = true;
    graphics = {
      enable = lib.mkForce true;
      enable32Bit = lib.mkForce false;
      extraPackages = with pkgs; [intel-media-driver vpl-gpu-rt]; # intel-compute-runtime
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    auditd.enable = false;
    allowSimultaneousMultithreading = true;
    protectKernelImage = lib.mkForce true;
    audit = {
      enable = lib.mkForce false;
      backlogLimit = 512;
      failureMode = "panic";
      rules = ["-a exit,always -F arch=b64 -S execve"];
    };
    apparmor = {
      enable = lib.mkForce true;
      killUnconfinedConfinables = lib.mkForce true;
    };
    dhparams = {
      enable = true;
      stateful = false;
      defaultBitSize = "3072";
    };
    sudo-rs = {
      enable = true;
      execWheelOnly = lib.mkForce true;
      wheelNeedsPassword = lib.mkForce true;
    };
    pam = {
      u2f = {
        enable = true;
        control = "sufficient";
        settings = {
          cue = true;
          debug = false;
        };
      };
      yubico = {
        enable = true;
        debug = false;
        mode = "challenge-response";
      };
      services = {
        login = {
          allowNullPassword = lib.mkForce false;
          failDelay = {
            enable = true;
            delay = 500000;
          };
          logFailures = true;
          u2fAuth = true;
          unixAuth = true;
          yubicoAuth = true;
        };
        sudo = {
          allowNullPassword = lib.mkForce false;
          failDelay = {
            enable = true;
            delay = 500000;
          };
          logFailures = true;
          requireWheel = true;
          u2fAuth = true;
          unixAuth = true;
          yubicoAuth = true;
        };
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = null; # disable root account
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # disable pubkey auth
      };
    };
  };

  ##############
  #-=# I18N #=-#
  ##############
  i18n = {
    defaultLocale = "en_US.UTF-8";
    # extraLocales = ["C.UTF-8" "de_DE.UTF-8"];
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "C.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shells = [pkgs.bashInteractive];
    systemPackages = with pkgs; [cryptsetup libargon2 libsmbios lsof moreutils nix-output-monitor nvme-cli openssl pam_u2f smartmontools];
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  # networking: ethernet, localhost, virtual, container: see systemd.networking, wifi client: networkmanager
  networking = {
    domain = "lan";
    enableIPv6 = false;
    nameservers = ["127.0.0.53"]; # systemd-resolved bind
    resolvconf.enable = false; # use systemd-resolved
    useNetworkd = true;
    usePredictableInterfaceNames = lib.mkDefault false;
    networkmanager = {
      enable = true;
      logLevel = "INFO";
      wifi = {
        backend = "wpa_supplicant"; # wpa_supplicant
        scanRandMacAddress = false;
        macAddress = "permanent"; # allow wifi mac filter
        powersave = false;
      };
    };
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = lib.mkDefault true;
      trustedInterfaces = [];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network = {
      enable = true;
      wait-online.enable = false;
      networks."10-lan" = {
        ipv6Prefixes = [{AddressAutoconfiguration = false;}];
        matchConfig.Name = "eth0";
        networkConfig.DHCP = "ipv4";
        linkConfig.RequiredForOnline = "yes";
      };
    };
    targets = {
      sleep.enable = true;
      suspend.enable = lib.mkForce false;
      hybrid-sleep.enable = lib.mkForce false;
      hibernate.enable = lib.mkForce false;
    };
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowHybridSleep=no
      AllowSuspendThenHibernate=no
    '';
    services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "info";
  };

  #########################
  #-=# POWERMANAGEMENT #=-#
  #########################
  powerManagement = {
    enable = true;
    powertop.enable = false;
    # cpuFreqGovernor = "ondemand";
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    acpid.enable = lib.mkForce true;
    avahi.enable = lib.mkForce false;
    devmon.enable = lib.mkForce false;
    fwupd.enable = true; # enable manually
    geoclue2.enable = lib.mkForce false;
    gvfs.enable = lib.mkForce false;
    openssh.enable = false;
    smartd.enable = true;
    power-profiles-daemon.enable = lib.mkForce false;
    udisks2.enable = lib.mkForce false;
    logind.settings.Login.HandleHibernateKey = "ignore";
    lvm = {
      enable = lib.mkDefault false;
      dmeventd.enable = lib.mkDefault false;
      boot = {
        thin.enable = lib.mkDefault false;
        vdo.enable = lib.mkDefault false;
      };
    };
    journald = {
      audit = true;
      storage = "persistent";
      upload.enable = false;
    };
    fstrim = {
      enable = true;
      interval = "daily";
    };
    resolved = {
      enable = true;
      dnssec = "false"; # XXX disable dnssec for the clowns pointless mitm
      extraConfig = "MulticastDNS=false\nCache=true\nCacheFromLocalhost=true\nDomains=~.\n";
      fallbackDns = ["192.168.80.1" "192.168.0.1" "192.168.1.1"];
      llmnr = "false";
    };
    tlp = {
      enable = true;
      settings = {
        # info => tlp-stat
        USB_AUTOSUSPEND = "0";
        DEVICES_TO_ENABLE_ON_STARTUP = "bluetooth wifi wwan";
        DEVICES_TO_ENABLE_ON_AC = "bluetooth wifi wwan";
        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "";
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "";
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "";
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "bluetooth wifi wwan";
        DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT = "bluetooth wifi wwan";
        DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT = "bluetooth wifi wwan";
        DEVICES_TO_ENABLE_ON_UNDOCK = "bluetooth wifi wwan";
        DEVICES_TO_DISABLE_ON_UNDOCK = "";
        START_CHARGE_THRESH_BAT0 = 45;
        STOP_CHARGE_THRESH_BAT0 = 85;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        RADEON_DPM_PERF_LEVEL_ON_AC = "low";
        RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
        RADEON_DPM_STATE_ON_AC = "battery";
        RADEON_DPM_STATE_ON_BAT = "battery";
        RADEON_POWER_PROFILE_ON_AC = "low";
        RADEON_POWER_PROFILE_ON_BAT = "low";
        WOL_DISABLE = "Y";
        WIFI_PWR_ON_AC = "on";
        WIFI_PWR_ON_BAT = "on";
      };
    };
    usbguard = {
      enable = false;
      rules = ''
        allow with-interface all-of { 03:*:* } # HID
        allow with-interface all-of { 08:*:* } # Storage
        reject with-interface all-of { 08:*:* 03:00:* }
        reject with-interface all-of { 08:*:* 03:01:* }
        reject with-interface all-of { 08:*:* e0:*:* }
        reject with-interface all-of { 08:*:* 02:*:* }
        allow with-interface one-of { 03:00:01 03:01:01 } if !allowed-matches(with-interface one-of { 03:00:01 03:01:01 })
      '';
    };
    udev.packages = [pkgs.yubikey-personalization];
  };
}
