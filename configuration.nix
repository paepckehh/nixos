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
    ./modules/hardening.nix
  ];

  #############
  #-=# NIX #=-#
  #############
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes ";
    settings = {
      auto-optimise-store = true;
      trusted-users = lib.mkForce ["root" "@wheel"];
      allowed-users = lib.mkForce ["@users" "@wheel"];
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "daily";
      options = "--delete-older-than 12d";
    };
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "uas" "sd_mod" "nvme"];
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

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    enableIPv6 = lib.mkDefault false;
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    proxy = {
      noProxy = "1270.0.1,local,localhost,localdomain,nixos";
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
      me = {
        description = "minimal-env-admin";
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7";
        uid = 1000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = ["wheel" "networkmanager" "video" "docker" "libvirt"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
      user = {
        description = "normal-user";
        initialHashedPassword = "$y$j9T$LHspGdWTX1m6WpLsN6xvH.$Ewnrv.azy5vko2dySQxtYZc2G3W5VpeIbhMBRxoO5TC";
        uid = 10000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        useDefaultShell = true;
        extraGroups = ["video"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    useUserPackages = true;
    users = {
      #################
      #-=# USER:ME #=-#
      #################
      me = {
        home = {
          stateVersion = "24.05";
          username = "me";
          homeDirectory = "/home/me";
          keyboard.layout = "us,de";
          shellAliases = {
            e = "vim";
            l = "ls -la";
            cat = "bat --paging=never";
            man = "batman";
            ll = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
            la = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
            lt = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
            lo = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
            li = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
          };
          sessionVariables = {
            EDITOR = "vim";
            PAGER = "bat";
          };
        };
        file = {
          ".config/starship.toml".source = builtins.readFile (builtins.fetchurl {url = "https://starship.rs/presets/toml/gruvbox-rainbow.toml";});
        };
        fonts.fontconfig.enable = true;
        programs = {
          fzf.enable = true;
          thefuck.enable = true;
          home-manager.enable = true;
          starship.enable = true;
          gitui.enable = true;
          zoxide.enable = true;
          bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch prettybat];
          };
          eza = {
            enable = true;
            git = true;
            icons = true;
            extraOptions = ["--group-directories-first" "--header"];
          };
          fd = {
            enable = true;
            extraOptions = ["--absolute-path" "--no-ignore"];
          };
          git = {
            enable = true;
            userName = "PAEPCKE, Michael";
            userEmail = "git@github.com";
          };
          vim = {
            enable = true;
            defaultEditor = true;
            plugins = [vimPlugins.vim-shellcheck vimPlugins.vim-go vimPlugins.vim-git];
            settings = {
              expandtab = true;
              history = 1000;
            };
            extraConfig = ''
              set nocompatible
              set nobackup '';
          };
          zsh = {
            enable = true;
            autocd = true;
            autosuggestion.enable = true;
            defaultKeymap = "viins";
            syntaxHighlighting.enable = true;
            historySubstringSearch.enable = true;
            history = {
              extended = true;
              ignoreSpace = true;
              share = true;
            };
          };
        };
      };
      ###################
      #-=# USER:USER #=-#
      ###################
      user = {
        home = {
          stateVersion = "24.05";
          username = "user";
          homeDirectory = "/home/user";
        };
        programs = {
          home-manager.enable = true;
        };
      };
    };
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    direnv.enable = true;
    gnupg.agent.enable = true;
    htop.enable = true;
    iftop.enable = true;
    iotop.enable = true;
    nano.enable = false;
    nix-index.enable = false;
    usbtop.enable = true;
    fzf.fuzzyCompletion = true;
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
      package = pkgs.vim-full;
      defaultEditor = true;
    };
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
  };
  nixpkgs.config.allowUnfree = true;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    memoryAllocator.provider = lib.mkForce "libc"; # hardening: scudo
    interactiveShellInit = ''uname -a '';
    variables = {
      VISUAL = "vim";
      EDITOR = "vim";
      SHELLCHECK_OPTS = "-e SC2086";
      SCUDO_OPTIONS = lib.mkDefault "ZeroContents=1";
    };
    systemPackages = with pkgs; [
      alejandra
      bandwhich
      fd
      go
      gopass
      gh
      git-crypt
      git-agecrypt
      dust
      hyperfine
      jq
      tldr
      tree
      paper-age
      passage
      procs
      rage
      ripgrep
      shfmt
      shellcheck
      moreutils
      vulnix
      yq
    ];
    shells = [pkgs.bashInteractive pkgs.zsh];
    shellAliases = {
      l = "ls -la";
      e = "vim";
      h = "htop --tree --highlight-changes";
      p = "sudo powertop";
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
    fstrim = {
      enable = true;
      interval = "daily";
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
