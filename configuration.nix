{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./hardware-configuration.nix
    ./modules/buildnix.nix
    ./modules/chronyPublic.nix
  ];

  #############
  #-=# NIX #=-#
  #############
  nix = {
    enable = true;
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes ";
    optimise.automatic = true;
    settings = {
      # store = lib.mkForce "https://cache.nixos.org";
      # substituters = lib.mkForce ["https://cache.nixos.org"]; # todo
      allowed-uris = lib.mkForce ["https://github.com/NixOS" "https://github.com/paepckehh" "https://cache.nixos.org"];
      flake-registry = lib.mkForce "file:///etc/nixos/flake-registry.json";
      use-registries = true;
      auto-optimise-store = true;
      allowed-users = lib.mkForce ["@wheel"];
      trusted-users = lib.mkForce ["@wheel"];
      http2 = lib.mkForce false;
      sandbox = lib.mkForce true;
      sandbox-build-dir = "/build";
      sandbox-fallback = lib.mkForce false;
      extra-sandbox-paths = [config.programs.ccache.cacheDir];
      trace-verbose = true;
      restrict-eval = lib.mkForce true;
      require-sigs = lib.mkForce true;
      preallocate-contents = true;
      trusted-public-keys = lib.mkForce ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "daily";
      options = "--delete-older-than 12d";
    };
  };

  #############
  #-=# NIX #=-#
  #############
  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
    };
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    readOnlyNixStore = lib.mkForce true;
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = lib.mkForce pkgs.linuxPackages_hardened;
    kernelParams = ["slab_nomerge" "page_poison=1" "page_alloc.shuffle=1" "debugfs=off" "ipv6.disable=1"];
    extraModulePackages = with pkgs; [];
    initrd = {
      systemd.enable = lib.mkForce false;
      luks.mitigateDMAAttacks = lib.mkForce true;
      availableKernelModules = ["aesni_intel" "cryptd" "sd_mod" "uas" "nvme" "xhci_pci"];
    };
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 4;
      };
    };
    kernel.sysctl = {
      "kernel.ftrace_enabled" = lib.mkForce false;
      "kernel.kptr_restrict" = lib.mkForce 2;
      "net.core.bpf_jit_enable" = lib.mkForce false;
      "net.ipv4.conf.all.log_martians" = lib.mkForce true;
      "net.ipv4.conf.all.rp_filter" = lib.mkForce "1";
      "net.ipv4.conf.default.log_martians" = lib.mkForce true;
      "net.ipv4.conf.default.rp_filter" = lib.mkForce "1";
      "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkForce true;
      "net.ipv4.conf.all.accept_redirects" = lib.mkForce false;
      "net.ipv4.conf.all.secure_redirects" = lib.mkForce false;
      "net.ipv4.conf.default.accept_redirects" = lib.mkForce false;
      "net.ipv4.conf.default.secure_redirects" = lib.mkForce false;
      "net.ipv6.conf.all.accept_redirects" = lib.mkForce false;
    };
    blacklistedKernelModules = ["ax25" "netrom" "rose" "affs" "bfs" "befs" "freevxfs" "f2fs" "hpfs" "jfs" "minix" "nilfs2" "omfs" "qnx4" "qnx6" "sysv"];
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
      flags = ["--update-input" "nixpkgs" "--update-input" "nixos-hardware" "--update-input" "home-manager" "--commit-lock-file"];
      operation = "switch"; # switch or boot
      persistent = true;
      randomizedDelaySec = "15min";
      rebootWindow = {
        lower = "02:00";
        upper = "04:00";
      };
    };
  };
  hardware = {
    enableRedistributableFirmware = true;
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  console = {
    earlySetup = true;
  };
  time = {
    timeZone = "Europe/Berlin";
    hardwareClockInLocalTime = false;
  };
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    auditd.enable = true;
    allowSimultaneousMultithreading = true; # xxx
    lockKernelModules = lib.mkForce true;
    protectKernelImage = lib.mkForce true;
    forcePageTableIsolation = lib.mkForce true;
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
    audit = {
      enable = lib.mkForce true;
      failureMode = "panic";
      rules = ["-a exit,always -F arch=b64 -S execve"];
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    enableIPv6 = lib.mkForce false;
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
      checkReversePath = true;
    };
    proxy = {
      noProxy = "1270.0.1,local,localhost,localdomain,192.168.0.0/16";
      default = "";
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
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
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
    gnupg.agent.enable = true;
    htop.enable = true;
    iftop.enable = true;
    iotop.enable = true;
    usbtop.enable = true;
    zsh.enable = true;
    ccache = {
      enable = false;
      packageNames = [];
    };
    ssh = {
      pubkeyAcceptedKeyTypes = ["ssh-ed25519" "ssh-rsa"];
      ciphers = ["chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com"];
      hostKeyAlgorithms = ["ssh-ed25519" "ssh-rsa"];
      kexAlgorithms = [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
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
        commit.gpgsign = "true";
        init.defaultBranch = "main";
        safe.directory = "/etc/nixos";
        gpg.format = "ssh";
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
          https.allow = "never";
        };
        url = {
          "git@github.com/" = {insteadOf = ["gh:" "github:" "github.com" "https://github.com" "https://git.github.com"];};
          "git@gitlab.com/" = {insteadOf = ["gl:" "gitlab:" "gitlab.com" "https://gitlab.com" "https://git.gitlab.com"];};
          "git@codeberg.org/" = {insteadOf = ["cb:" "codeberg:" "codeberg.org" "https://codeberg.org" "https://git.codeberg.org"];};
        };
      };
    };
    vim = {
      enable = true;
      package = pkgs.vim-full;
      defaultEditor = true;
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    memoryAllocator.provider = lib.mkForce "libc"; # hardening: scudo
    interactiveShellInit = ''uname -a'';
    variables = {
      VISUAL = "vim";
      EDITOR = "vim";
      # SCUDO_OPTIONS = lib.mkForce "ZeroContents=1";
    };
    systemPackages = with pkgs; [alejandra];
    shells = [pkgs.bashInteractive pkgs.zsh];
    shellAliases = {
      l = "ls -la";
      e = "vim";
      h = "htop --tree --highlight-changes";
      s = "nix-ccache --show-stats";
      slog = "journalctl --follow --priority=7 --lines=100";
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
    opensnitch = {
      enable = false;
      settings = {
        firewall = "nftables"; # iptables or nftables
        defaultAction = "deny"; # allow or deny
      };
    };
    kmscon = {
      enable = false;
      hwRender = true;
    };
    fstrim = {
      enable = true;
      interval = "daily";
    };
    resolved = {
      enable = true;
      dnssec = "true";
      fallbackDns = ["9.9.9.10" "9.9.9.9"];
      extraConfig = ''DNSOverTLS=yes '';
    };
    openssh = {
      enable = false;
      allowSFTP = false;
      settings = {
        PasswordAuthentication = false;
        StrictModes = true;
        challengeResponseAuthentication = false;
      };
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey '';
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = "8022";
        }
      ];
    };
  };
}
