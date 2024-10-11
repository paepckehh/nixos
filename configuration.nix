{
  config,
  pkgs,
  lib,
  home-manager,
  modulesPath,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./alias/nixops.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  #############
  #-=# NIX #=-#
  #############
  nix = {
    enable = true;
    daemonCPUSchedPolicy = "idle";
    package = pkgs.nixFlakes;
    extraOptions = ''
      builders-use-substitutes = false
      experimental-features = nix-command flakes'';
    settings = {
      auto-optimise-store = true;
      allowed-users = lib.mkForce ["@wheel"];
      trusted-users = lib.mkForce ["@wheel"];
      flake-registry = "";
      http2 = lib.mkForce false;
      sandbox = lib.mkForce true;
      sandbox-build-dir = "/build";
      sandbox-fallback = lib.mkForce false;
      trace-verbose = true;
      restrict-eval = lib.mkForce true;
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
      options = "--delete-older-than 14d";
    };
    optimise = {
      automatic = true;
      dates = ["daily"];
    };
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

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = {
    "/" = {
      fsType = "ext4";
      device = "/dev/disk/by-diskseq/1-part2";
      options = ["noatime" "nodiratime" "discard"];
    };
    "/boot" = {
      fsType = "vfat";
      device = "/dev/disk/by-diskseq/1-part1"; # always boot from drive one
      options = ["fmask=0022" "dmask=0022"];
    };
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    blacklistedKernelModules = ["ax25" "netrom" "rose" "affs" "bfs" "befs" "freevxfs" "f2fs" "hpfs" "jfs" "minix" "nilfs2" "omfs" "qnx4" "qnx6" "sysv"];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["page_alloc.shuffle=1" "ipv6.disable=1"];
    kernelModules = ["vfat" "exfat"];
    readOnlyNixStore = lib.mkForce true;
    initrd = {
      systemd.enable = lib.mkForce false;
      availableKernelModules = ["ahci" "dm_mod" "sd_mod" "sr_mod" "nvme" "mmc_block" "uas" "usbhid" "usb_storage" "xhci_pci"];
    };
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
      tmpfsSize = "85%";
    };
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
      "net.core.bpf_jit_enable" = lib.mkForce false;
      "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkForce true;
      "net.ipv4.conf.all.accept_redirects" = lib.mkForce false;
      "net.ipv4.conf.all.secure_redirects" = lib.mkForce false;
      "net.ipv4.conf.default.accept_redirects" = lib.mkForce false;
      "net.ipv4.conf.default.secure_redirects" = lib.mkForce false;
      "net.ipv6.conf.all.accept_redirects" = lib.mkForce false;
    };
  };

  ###############
  #-= SYSTEM #=-#
  ###############
  system = {
    stateVersion = "24.05"; # dummy target, do not modify
    switch.enable = true; # allow updates
    autoUpgrade = {
      enable = false;
      allowReboot = true;
      dates = "hourly";
      flake = "github.com/paepckehh/nixos";
      flags = ["--update-input" "nixpkgs" "--update-input" "nixpkgs-Release" "--update-input" "home-manager" "--commit-lock-file"];
      operation = "switch"; # switch or boot
      persistent = true;
      randomizedDelaySec = "15min";
      rebootWindow = {
        lower = "02:00";
        upper = "04:00";
      };
    };
  };
  time = {
    timeZone = null; # UTC, local: "Europe/Berlin";
    hardwareClockInLocalTime = true;
  };
  powerManagement = {
    enable = true;
    powertop.enable = false;
    cpuFreqGovernor = "balanced";
  };
  console = {
    earlySetup = lib.mkForce true;
    keyMap = "us";
    font = "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v18b.psf.gz";
    packages = with pkgs; [powerline-fonts];
  };
  swapDevices = [];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    targets = {
      sleep.enable = true;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    enableAllFirmware = lib.mkForce true;
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    auditd.enable = false;
    audit = {
      enable = lib.mkForce true;
      backlogLimit = 512;
      failureMode = "panic";
      rules = ["-a exit,always -F arch=b64 -S execve"];
    };
    allowSimultaneousMultithreading = true;
    lockKernelModules = lib.mkForce true;
    protectKernelImage = lib.mkForce true;
    apparmor = {
      enable = lib.mkForce true;
      killUnconfinedConfinables = lib.mkForce true;
    };
    dhparams = {
      enable = true;
      stateful = false;
      defaultBitSize = "3072";
    };
    doas = {
      enable = false;
      wheelNeedsPassword = lib.mkForce true;
    };
    sudo = {
      enable = false;
      execWheelOnly = lib.mkForce true;
      wheelNeedsPassword = lib.mkForce true;
    };
    sudo-rs = {
      enable = true;
      execWheelOnly = lib.mkForce true;
      wheelNeedsPassword = lib.mkForce true;
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    useDHCP = lib.mkDefault true;
    enableIPv6 = lib.mkForce false;
    usePredictableInterfaceNames = false;
    networkmanager.enable = true;
    wireguard.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
      checkReversePath = true;
    };
    proxy = {
      default = "";
      noProxy = "lan,local,localhost,localdomain,127.0.0.0/8,192.168.0.0/16,10.0.0.0/8";
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
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    nano.enable = true;
    htop.enable = true;
    iftop.enable = true;
    iotop.enable = true;
    usbtop.enable = true;
    wireshark.enable = true;
    zsh.enable = true;
    ssh = {
      startAgent = lib.mkForce true;
      extraConfig = "AddKeysToAgent yes";
      hostKeyAlgorithms = ["ssh-ed25519" "sk-ssh-ed25519@openssh.com"];
      pubkeyAcceptedKeyTypes = ["ssh-ed25519" "sk-ssh-ed25519@openssh.com"];
      ciphers = ["chacha20-poly1305@openssh.com"];
      kexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
      knownHosts = {
        github = {
          extraHostNames = ["github.com" "api.github.com" "git.github.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
        gitlab = {
          extraHostNames = ["gitlab.com" "api.gitlab.com" "git.gitlab.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
        };
        codeberg = {
          extraHostNames = ["codeberg.org" "api.codeberg.org" "git.codeberg.org"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
        };
        sourcehut = {
          extraHostNames = ["sr.ht" "api.sr.ht" "git.sr.ht"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
        };
      };
    };
    git = {
      enable = true;
      prompt.enable = true;
      config = {
        branch.sort = "-committerdate";
        commit.gpgsign = false;
        init.defaultBranch = "main";
        safe.directory = "/etc/nixos";
        gpg.format = "ssh";
        user = {
          email = "nix@nixos.local";
          name = "NIXOS, Generic Local";
          signingkey = "~/.ssh/id_ed25519.pub";
        };
        http = {
          sslVerify = "true";
          sslVersion = "tlsv1.3";
          version = "HTTP/1.1";
        };
        protocol = {
          allow = "never";
          file.allow = "always";
          git.allow = "never";
          ssh.allow = "always";
          http.allow = "never";
          https.allow = "always";
        };
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    etc."lvm/lvm.conf".text = lib.mkForce ''
      devices { 
         issue_discards = 1 
      }
      allocations { 
        thin_pool_discards = 1 
      }'';
    interactiveShellInit = ''uname -a && eval "$(ssh-agent)"'';
    systemPackages = with pkgs; [alejandra wireguard-tools];
    shells = [pkgs.bashInteractive pkgs.zsh];
    shellAliases = {
      l = "ls -la";
      e = "vim";
      h = "htop --tree --highlight-changes";
      slog = "journalctl --follow --priority=7 --lines=2500";
    };
    variables = {
      VISUAL = "vim";
      EDITOR = "vim";
    };
  };

  ##############
  #-=# I18N #=-#
  ##############
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  ###############
  #-=# FONTS #=-#
  ###############
  fonts = {
    packages = with pkgs; [(nerdfonts.override {fonts = ["FiraCode"];})];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    power-profiles-daemon.enable = true;
    thermald.enable = true;
    logind.hibernateKey = "ignore";
    fstrim = {
      enable = true;
      interval = "daily";
    };
    usbguard = {
      enable = false;
      rules = ''
        allow with-interface one-of { 02:*:* 08:*:* 09:*:* 11:*:* }
        reject with-interface all-of { 08:*:* 03:00:* }
        reject with-interface all-of { 08:*:* 03:01:* }
        reject with-interface all-of { 08:*:* e0:*:* }
        reject with-interface all-of { 08:*:* 02:*:* }
        allow with-interface one-of { 03:00:01 03:01:01 } if !allowed-matches(with-interface one-of { 03:00:01 03:01:01 })
      '';
    };
  };
}
