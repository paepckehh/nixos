{
  config,
  pkgs,
  lib,
  ...
}: {
  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  # some minimum sane fallback defaults, details: see storage folder
  fileSystems = lib.mkDefault {
    "/" = {
      fsType = "ext4";
      device = "/dev/disk/by-partlabel/disk-main-root";
      options = ["noatime" "nodiratime" "discard"];
    };
    "/boot" = lib.mkDefault {
      fsType = "vfat";
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      compressor = "zstd";
      compressorArgs = ["--ultra" "--long" "-22"];
      systemd.enable = true;
      luks.mitigateDMAAttacks = lib.mkForce true;
      availableKernelModules = ["aesni_intel" "ahci" "applespi" "applesmc" "dm_mod" "cryptd" "intel_lpss_pci" "nvme" "thunderbolt" "uas" "usbhid" "usb_storage" "xhci_pci"];
    };
    blacklistedKernelModules = ["affs" "b43" "befs" "bfs" "brcmfmac" "brcmsmac" "bcma" "freevxfs" "hpfs" "jfs" "minix" "nilfs2" "omfs" "qnx4" "qnx6" "k10temp" "ssb" "wl"];
    extraModulePackages = [config.boot.kernelPackages.zenpower];
    kernelPackages = (
      if (config.system.nixos.release == "24.11")
      then pkgs.linuxPackages
      else pkgs.linuxPackages_latest
    );
    kernelParams = ["amd_pstate=active" "copytoram" "page_alloc.shuffle=1"];
    kernelModules = ["amd-pstate" "amdgpu" "exfat" "kvm-amd" "kvm-intel" "uas" "vfat"];
    readOnlyNixStore = lib.mkForce true;
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
      tmpfsSize = "85%";
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
    kernel.sysctl = {
      "kernel.kptr_restrict" = lib.mkForce 2;
      "kernel.ftrace_enabled" = lib.mkForce false;
      "net.core.rmem_max" = lib.mkForce 7500000;
      "net.core.wmem_max" = lib.mkForce 7500000;
      "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkForce true;
      "net.ipv4.conf.all.accept_redirects" = lib.mkForce false;
      "net.ipv4.conf.all.secure_redirects" = lib.mkForce false;
      "net.ipv4.conf.default.accept_redirects" = lib.mkForce false;
      "net.ipv4.conf.default.secure_redirects" = lib.mkForce false;
      "net.ipv6.conf.all.disable_ipv6" = lib.mkForce true;
      "net.ipv6.conf.all.accept_redirects" = lib.mkForce false;
    };
  };

  ###############
  #-= SYSTEM #=-#
  ###############
  system = {
    stateVersion = "25.05"; # dummy target, do not modify
    switch.enable = true; # allow nix store updates
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
    priority = 100;
  };

  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs = {
    config = {
      allowBroken = lib.mkDefault true;
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
        "https://nixpkgs-unfree.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      substituters = [
        "https://nixpkgs-unfree.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    gc = {
      automatic = true;
      dates = "daily";
      persistent = true;
      options = "--delete-older-than 60d";
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
    man.enable = lib.mkForce true;
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

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
  };

  ##############
  #-=# I18N #=-#
  ##############
  i18n = {
    defaultLocale = "en_US.UTF-8"; # "de_DE.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8"; # "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "en_US.UTF-8"; # "de_DE.UTF-8";
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    interactiveShellInit = ''uname -a && eval "$(ssh-agent)"'';
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
      ROC_ENABLE_PRE_VEGA = "1";
    };
    shells = [pkgs.bashInteractive pkgs.zsh];
    shellAliases = {
      "e" = "vim";
      "l" = "ls -la";
      "log.boot" = "sudo dmesg --follow --human --kernel --userspace";
      "log.system" = "journalctl --follow --priority=7 --lines=2500";
      "info.nvme" = "sudo smartctl --all /dev/sda"; # /dev/nvme0
      "service.log.clean" = "sudo journalctl --vacuum-time=1d";
      "service.log.follow" = "sudo journalctl --follow -u $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.log.today" = "sudo journalctl --pager-end --since today -u $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.start" = "sudo systemctl start $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.stop" = "sudo systemctl stop $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.status" = "sudo systemctl status $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.restart" = "sudo systemctl restart $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  # networking: ethernet, localhost, virtual, container: see systemd.networking, wifi client: networkmanager
  networking = {
    enableIPv6 = false;
    nameservers = ["127.0.0.53"]; # resolved stub
    resolvconf.enable = false; # use systemd-resolved
    useNetworkd = true;
    usePredictableInterfaceNames = false;
    networkmanager = {
      enable = true;
      logLevel = "INFO";
      wifi = {
        backend = "wpa_supplicant";
        scanRandMacAddress = false;
        macAddress = "permanent"; # allow wifi mac filter
        powersave = false;
      };
    };
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = true;
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
    network = {
      enable = true;
      wait-online.enable = false;
      networks."10-lan" = {
        matchConfig.Name = "eth0";
        networkConfig.DHCP = "ipv4";
        linkConfig.RequiredForOnline = "no";
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
  };

  #########################
  #-=# POWERMANAGEMENT #=-#
  #########################
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "ondemand";
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    acpid.enable = lib.mkForce true;
    avahi.enable = lib.mkForce false;
    devmon.enable = lib.mkForce false;
    fwupd.enable = true;
    geoclue2.enable = lib.mkForce false;
    gvfs.enable = lib.mkForce false;
    openssh.enable = false;
    smartd.enable = true;
    pcscd.enable = false;
    power-profiles-daemon.enable = lib.mkForce false;
    udisks2.enable = lib.mkForce false;
    logind.hibernateKey = "ignore";
    lvm = {
      enable = true;
      dmeventd.enable = true;
      boot = {
        thin.enable = true;
        vdo.enable = true;
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
      fallbackDns = ["192.168.8.1" "192.168.0.1" "192.168.1.1"];
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
  };
}
