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
    consoleLogLevel = 4;
    blacklistedKernelModules = ["affs" "befs" "bfs" "freevxfs" "hpfs" "jfs" "minix" "nilfs2" "omfs" "qnx4" "qnx6" "k10temp" "ssb"];
    nixStoreMountOpts = lib.mkForce ["ro"];
    hardwareScan = true;
    runSize = "85%";
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = lib.mkDefault true;
        consoleMode = "max";
        configurationLimit = 24;
      };
    };
    initrd = {
      systemd = {
        enable = lib.mkDefault true;
        emergencyAccess = lib.mkDefault false;
      };
      luks.mitigateDMAAttacks = lib.mkForce true;
      supportedFilesystems = ["ext4" "tmpfs" "vfat"]; # zfs
      availableKernelModules = ["ahci" "dm_mod" "cryptd" "nvme" "thunderbolt" "sd_mod" "uas" "usbhid" "usb_storage" "xhci_pci"];
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["page_alloc.shuffle=1"];
    tmp = {
      cleanOnBoot = true;
      tmpfsHugeMemoryPages = "within_size";
      tmpfsSize = "85%";
      useTmpfs = lib.mkForce true;
      useZram = lib.mkForce false;
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
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_rfc1337" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv6.conf.all.disable_ipv6" = 1;
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
  system.stateVersion = "26.05"; # dummy target, do not modify

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
    font = "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v18b.psf.gz";
    packages = with pkgs; [powerline-fonts];
  };

  #############
  #-= SWAP #=-#
  #############
  swapDevices = lib.mkForce []; # keep
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
    extraOptions = ''
      builders-use-substitutes = false
      experimental-features = nix-command flakes'';
    settings = {
      auto-optimise-store = true;
      allowed-users = lib.mkForce ["@wheel"];
      trusted-users = lib.mkForce ["@wheel"];
      http2 = lib.mkDefault true;
      sandbox = lib.mkForce true;
      sandbox-build-dir = "/build";
      sandbox-fallback = lib.mkForce false;
      trace-verbose = true;
      restrict-eval = lib.mkForce false;
      require-sigs = lib.mkForce true;
      preallocate-contents = lib.mkDefault true;
      allowed-uris = lib.mkDefault [
        "https://cache.nixos.org"
      ];
      substituters = lib.mkDefault [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = lib.mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    gc.automatic = lib.mkDefault false;
    optimise.automatic = lib.mkDefault false;
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
      cache.enable = lib.mkForce false;
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    enableAllFirmware = lib.mkForce true;
    enableRedistributableFirmware = lib.mkForce true;
    uinput.enable = true;
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
    systemPackages = with pkgs; [cryptsetup git libargon2 libsmbios util-linux lsof moreutils nix-output-monitor nvme-cli openssl pam_u2f smartmontools sbctl];
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    enableIPv6 = false;
    useNetworkd = true;
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
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = lib.mkDefault true;
      allowedTCPPorts = (
        if (config.services.openssh.enable == true)
        then [infra.port.ssh]
        else []
      );
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
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
    journald = {
      audit = false;
      storage = "volatile"; # persistent
      upload.enable = false;
    };
    fstrim = {
      enable = true;
      interval = "weekly"; # weekly, daily, 05:00
    };
    tlp = {
      enable = true;
      settings = {
        # use tlp-stat for more details, https://linrunner.de/tlp/
        USB_AUTOSUSPEND = "0";
        WOL_DISABLE = "Y";
        START_CHARGE_THRESH_BAT0 = 45;
        STOP_CHARGE_THRESH_BAT0 = 85;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
      };
    };
    openssh = {
      enable = lib.mkDefault false;
      authorizedKeysInHomedir = false;
      authorizedKeysCommandUser = "nobody";
      authorizedKeysCommand = "none";
      allowSFTP = false;
      startWhenNeeded = true;
      generateHostKeys = true;
      listenAddresses = lib.mkDefault [
        {
          addr = "0.0.0.0";
          port = infra.port.ssh-mgmt;
        }
      ];
      hostKeys = [
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
        # Match.Address."10.21.0.0/24".AllowUsers = ["backup"];
      };
    };
  };
}
