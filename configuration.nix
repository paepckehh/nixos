{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ./siteconfig/config.nix).infra;
in {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    blacklistedKernelModules = infra.kernel.blacklist;
    extraModprobeConfig = infra.kernel.modBlacklist;
    kernelPackages = pkgs.latestKernelPackage;
    nixStoreMountOpts = lib.mkForce ["ro" "nodev" "nosuid"];
    runSize = "85%";
    supportedFilesystems = infra.kernel.fs.base;
    initrd = {
      availableKernelModules = infra.kernel.whitelist.base;
      supportedFilesystems = infra.kernel.fs.base;
      luks.mitigateDMAAttacks = lib.mkForce true;
      systemd = {
        enable = lib.mkDefault true;
        emergencyAccess = lib.mkForce false;
      };
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = lib.mkDefault true;
        consoleMode = "max";
        configurationLimit = 24;
        editor = lib.mkForce false;
      };
    };
    tmp = {
      cleanOnBoot = true;
      tmpfsHugeMemoryPages = "within_size";
      tmpfsSize = "85%";
      useTmpfs = lib.mkForce true;
      useZram = lib.mkForce false;
    };
  };

  ###############
  #-= SYSTEM #=-#
  ###############
  system = {
    stateVersion = "26.05"; # dummy target
    includeBuildDependencies = lib.mkForce false;
  };

  #############
  #-= TIME #=-#
  #############
  time = {
    timeZone = infra.locale.tz;
    hardwareClockInLocalTime = true;
  };

  ################
  #-= CONSOLE #=-#
  ################
  console = {
    enable = lib.mkForce true;
    earlySetup = lib.mkForce true;
    keyMap = infra.locale.keymap;
  };

  #############
  #-= SWAP #=-#
  #############
  swapDevices = lib.mkForce [];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    writebackDevice = lib.mkDefault "/dev/disk/by-partlabel/disk-main-swap";
  };

  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
    };
  };

  #############
  #-=# NIX #=-#
  #############
  nix = {
    enable = true;
    daemonCPUSchedPolicy = "idle";
    gc.automatic = lib.mkDefault false;
    optimise.automatic = lib.mkDefault false;
    settings = {
      auto-optimise-store = true;
      allowed-users = lib.mkForce ["@wheel"];
      build-dir = "/run/build";
      experimental-features = ["blake3-hashes" "local-overlay-store" "nix-command" "flakes" "verified-fetches"];
      http2 = lib.mkForce false;
      http-connections = lib.mkForce 10; # default: 25
      sandbox = lib.mkForce true;
      sandbox-build-dir = "/run/build";
      sandbox-fallback = lib.mkForce false;
      stalled-download-timeout = lib.mkDefault "8000";
      trusted-users = lib.mkForce ["@wheel"];
      trace-verbose = true;
      restrict-eval = lib.mkForce false;
      require-sigs = lib.mkForce true;
      preallocate-contents = lib.mkDefault true;
      keep-build-log = lib.mkDefault false;
      keep-derivations = lib.mkDefault false;
      keep-failed = lib.mkDefault false;
      max-jobs = lib.mkDefault "auto"; # default: 1
      allowed-uris = lib.mkDefault [
        # "https://cache.nixos.org"
      ];
      substituters = lib.mkDefault [
        # "https://cache.nixos.org"
      ];
      trusted-public-keys = lib.mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
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
      cache.enable = lib.mkForce true;
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    enableAllFirmware = lib.mkForce false;
    enableRedistributableFirmware = lib.mkForce true;
    uinput.enable = true;
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    auditd.enable = false;
    allowSimultaneousMultithreading = true;
    lockKernelModules = lib.mkForce true;
    protectKernelImage = lib.mkForce true;
    audit = {
      enable = lib.mkForce false;
      backlogLimit = 512;
      failureMode = "panic";
      rules = ["-a exit,always -F arch=b64 -S execve"];
    };
    apparmor = {
      enable = lib.mkForce true;
      enableCache = lib.mkDefault true;
      killUnconfinedConfinables = lib.mkForce true;
      packages = with pkgs; [apparmor-profiles];
    };
    sudo-rs = {
      enable = true;
      execWheelOnly = lib.mkForce true;
      wheelNeedsPassword = lib.mkForce true;
      extraConfig = "Defaults   env_reset,timestamp_timeout=40,!pwfeedback";
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
      services = {
        login = {
          failDelay = {
            enable = true;
            delay = 3500000;
          };
          logFailures = true;
          u2fAuth = true;
          unixAuth = true;
        };
        sudo = {
          failDelay = {
            enable = true;
            delay = 3500000;
          };
          logFailures = true;
          requireWheel = true;
          u2fAuth = true;
          unixAuth = true;
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
        hashedPassword = lib.mkForce null; # disable
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
      backup = {
        hashedPassword = lib.mkForce null; # disable
        isSystemUser = true;
        group = "backup";
        openssh.authorizedKeys.keys = infra.backup.sshKeys;
      };
    };
    groups.backup.members = ["backup"];
  };

  ##############
  #-=# I18N #=-#
  ##############
  i18n = {
    defaultLocale = infra.locale.LC.global;
    extraLocaleSettings = {
      LC_ADDRESS = infra.locale.LC.regional;
      LC_IDENTIFICATION = infra.locale.LC.regional;
      LC_MEASUREMENT = infra.locale.LC.regional;
      LC_MONETARY = infra.locale.LC.regional;
      LC_NAME = infra.locale.LC.regional;
      LC_NUMERIC = infra.locale.LC.regional;
      LC_PAPER = infra.locale.LC.regional;
      LC_TELEPHONE = infra.locale.LC.regional;
      LC_TIME = infra.locale.LC.regional;
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shells = [pkgs.bashInteractive];
    systemPackages = with pkgs; [cryptsetup git libargon2 libsmbios util-linux lsof moreutils nix-output-monitor nvme-cli openssl rage ragenix pam_u2f smartmontools sbctl];
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    enableIPv6 = false;
    useNetworkd = true;
    useHostResolvConf = lib.mkForce false;
    networkmanager = {
      enable = true;
      logLevel = "INFO";
      unmanaged = ["enp1s0f4u2u1"];
      wifi = {
        backend = "wpa_supplicant"; # wpa_supplicant
        scanRandMacAddress = true;
        macAddress = "random"; # permanent, stable, random
        powersave = true;
      };
    };
    wireless = {
      fallbackToWPA2 = false;
      scanOnLowSignal = true;
    };
    timeServers = lib.mkDefault ["0.europe.pool.ntp.org" "1.europe.pool.ntp.org" "2.europe.pool.ntp.org" "3.europe.pool.ntp.org"];
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = lib.mkDefault true;
      allowedTCPPorts = (
        if (config.services.openssh.enable == true)
        then [infra.port.ssh-mgmt]
        else []
      );
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    enableEmergencyMode = lib.mkForce false;
    coredump.settings.Coredump = {
      Storage = "none";
      ProcessSizeMax = 0;
    };
    targets = {
      sleep.enable = true;
      suspend.enable = lib.mkForce false;
      hybrid-sleep.enable = lib.mkForce false;
      hibernate.enable = lib.mkForce false;
    };
    sleep.settings.Sleep = {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };
  };

  #########################
  #-=# POWERMANAGEMENT #=-#
  #########################
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    acpid.enable = lib.mkForce true;
    avahi.enable = lib.mkForce false;
    devmon.enable = lib.mkForce true;
    geoclue2.enable = lib.mkForce false;
    gvfs.enable = lib.mkForce false;
    hardware.bolt.enable = true;
    udisks2.enable = lib.mkForce true;
    fwupd.enable = lib.mkForce false;
    smartd.enable = lib.mkDefault true;
    power-profiles-daemon.enable = lib.mkForce false;
    logind.settings.Login.HandleHibernateKey = "ignore";
    libinput.enable = lib.mkForce true;
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = false;
        LLMNR = false;
        MulticastDNS = false;
        Cache = "no-negative";
        RefuseRecordTypes = "AAAA";
        StaleRetentionSec = 600;
      };
    };
    journald = {
      audit = false;
      storage = "volatile";
    };
    fstrim = {
      enable = true;
      interval = "weekly";
    };
    tlp = {
      enable = true;
      settings = {
        USB_AUTOSUSPEND = "0";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
        START_CHARGE_THRESH_BAT0 = 45;
        STOP_CHARGE_THRESH_BAT0 = 85;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        WOL_DISABLE = "Y";
      };
    };
    openssh = {
      enable = lib.mkDefault false;
      authorizedKeysInHomedir = false;
      authorizedKeysCommandUser = "nobody";
      authorizedKeysCommand = "none";
      allowSFTP = false;
      ports = [infra.port.ssh-mgmt];
      startWhenNeeded = true;
      generateHostKeys = true;
      hostKeys = lib.mkForce [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      settings = {
        AddressFamily = "inet";
        AllowAgentForwarding = false;
        AllowGroups = null;
        AllowUsers = ["me" "backup"];
        AuthenticationMethods = "publickey";
        AuthorizedPrincipalsFile = "none";
        ChallengeResponseAuthentication = "no";
        Ciphers = ["chacha20-poly1305@openssh.com"];
        ClientAliveInterval = "30";
        ClientAliveCountMax = "3";
        PerSourceMaxStartups = "12";
        PerSourceNetBlockSize = "32:128";
        Compression = "no";
        GatewayPorts = "no";
        HostKey = "/etc/ssh/ssh_host_ed25519_key";
        KbdInteractiveAuthentication = false;
        KexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
        LogLevel = "INFO"; # INFO, VERBOSE, DEBUG
        LoginGraceTime = "2m";
        Macs = null; #
        MaxStartups = "10:30:100";
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        PrintMotd = false;
        PubkeyAuthOptions = "touch-required";
        PubkeyAuthentication = "yes";
        RekeyLimit = "512M, 1h";
        StrictModes = true;
        UseDns = false;
        UsePAM = false;
        X11Forwarding = false;
        # Match.Address."192.168.0.0/24".AllowUsers = ["me"];
      };
    };
  };
}
