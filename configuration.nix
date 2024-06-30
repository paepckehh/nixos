{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  #############
  #-=# NIX #=-#
  #############
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes ";
    settings = {
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel"];
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
    kernelPackages = pkgs.linuxPackages_latest;
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      systemd-boot = {
        enable = false;
        configurationLimit = 32;
      };
      grub = {
        enable = true;
        enableCryptodisk = true;
        configurationLimit = 32;
        efiSupport = true;
        efiInstallAsRemovable = false;
        forceInstall = false;
        memtest86 = {
          enable = true;
          params = "";
        };
        splashImage = null;
        splashMode = "normal";
        theme = null;
        useOSProber = true;
        device = "/dev/sda";
        zfsSupport = false;
      };
    };
  };

  ###############
  #-= SYSTEM #=-#
  ###############
  system = {
    stateVersion = "24.05"; # dummy target, do not modify
    autoUpgrade = {
      enable = true;
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
    # hostName = "nixos";
    enableIPv6 = false;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    proxy = {
      noProxy = "1270.0.1,local,localhost,localdomain,nixos";
      default = "";
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    auditd.enable = true;
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

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root = {
        shell = pkgs.bashInteractive;
        hashedPassword = "!"; # disable root account
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-locked"];
      };
      me = {
        description = "default minimal envadmin account";
        initialPassword = "start-riot-bravo-charly-24";
        uid = 1000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        useDefaultShell = true;
        extraGroups = ["wheel" "networkmanager" "video" "docker" "libvirt"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-locked"];
      };
      user = {
        description = "default user account";
        initialPassword = "start-delta-echo-delta-24";
        uid = 10000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        useDefaultShell = true;
        extraGroups = [];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-locked"];
      };
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    useUserPackages = true;
    users.me = {
      home = {
        stateVersion = "24.05";
        username = "me";
        homeDirectory = "/home/me";
      };
      programs = {
        home-manager.enable = true;
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
      knownHosts.github = {
        extraHostNames = ["github.com" "api.github.com"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
    git = {
      enable = true;
      prompt.enable = true;
      config = {
        branch.sort = "-committerdate";
        init.defaultBranch = "main";
        safe.directory = "/etc/nixos";
        gpg.format = "ssh";
        commit.gpgsign = "true";
        url = {"https://github.com/" = {insteadOf = ["gh:" "github:"];};};
      };
    };
    vim = {
      package = pkgs.vim-full;
      defaultEditor = true;
    };
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
  nixpkgs.config.allowUnfree = true;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      alejandra
      bandwhich
      bat
      bat-extras.batman
      bat-extras.prettybat
      eza
      fd
      go
      gh
      dust
      hyperfine
      jq
      tldr
      tree
      procs
      ripgrep
      shfmt
      shellcheck
      moreutils
      vimPlugins.vim-shellcheck
      vimPlugins.vim-go
      vimPlugins.vim-git
      yq
    ];
    shells = [pkgs.bashInteractive pkgs.zsh];
    shellAliases = {
      l = "ls -la";
      ll = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
      la = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
      lt = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
      lo = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
      li = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
      e = "vim";
      h = "htop --tree --highlight-changes";
      p = "sudo powertop";
      d = "dmesg -Hw";
      cat = "bat --paging=never";
      less = "bat";
      man = "batman";
      slog = "journalctl --follow --priority=7 --lines=100";
      "nix.push" = ''
        cd /etc/nixos && \
        sudo -v && \
        sudo alejandra --quiet . && \
        sudo chown -R me:users .git &&\
        git reset && \
        git add . && \
        git commit -S -m update ; \
        git gc --aggressive ; \
        git push --force '';
      "nix.clean" = ''
        cd /etc/nixos && \
        sudo -v && \
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 12d ;\
        sudo nix-collect-garbage --delete-older-than 12d ;\
        sudo nix-store --gc ; \
        sudo nix-store --optimise '';
      "nix.hardclean" = ''
        cd /etc/nixos && \
        sudo -v && \
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 1d ;\
        sudo nix-collect-garbage --delete-older-than 1d ;\
        sudo nix-store --gc ; \
        sudo nix-store --optimise '';
      "nix.test" = ''
        cd /etc/nixos && \
        sudo -v && \
        sudo alejandra --quiet . ; \
        sudo nixos-rebuild dry-activate --flake /etc/nixos/.#$(hostname)'';
      "nix.build" = ''
        cd /etc/nixos && \
        sudo -v && \
        sudo alejandra --quiet . && \
        git reset && \
        git add . && \
        git commit -S -m update ; \
        export DTS="$(date '+%Y-%m-%d-%H-%M')" ;\
        export HNAME="$(hostname)" ;\
        sudo nixos-rebuild switch --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" '';
      "nix.update" = ''
        cd /etc/nixos && \
        sudo -v && \
        sudo alejandra --quiet . && \
        git reset && \
        git add . && \
        git commit -S -m update ; 
        sudo nix --verbose flake update && \
        sudo alejandra --quiet . && \
        sudo nixos-generate-config && \
        sudo alejandra --quiet . && \
        git reset && \
        git add . && \
        git commit -S -m update ; \
        export DTS="$(date '+%Y-%m-%d-%H-%M')" ;\
        export HNAME="$(hostname)" ;\
        sudo nixos-rebuild switch --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" '';
      "nix.all" = ''
        cd /etc/nixos && \
        sudo -v && \
        sudo alejandra --quiet . && \
        git reset && \
        git add . && \
        git commit -S -m update ; 
        sudo nix --verbose flake update && \
        sudo alejandra --quiet . && \
        sudo nixos-generate-config && \
        sudo alejandra --quiet . && \
        git reset && \
        git add . && \
        git commit -S -m update ; \
        export DTS="$(date '+%Y-%m-%d-%H-%M')" ; \
        export HNAME="$(hostname)" ; \
        sudo nixos-rebuild boot   --flake /etc/nixos/#nixmac182            -p "nixmac182-$DTS" -v ; \
        sudo nixos-rebuild boot   --flake /etc/nixos/#nixmac182-console    -p "nixmac182-console-$DTS" -v ; \
        sudo nixos-rebuild boot   --flake /etc/nixos/#nixmac182-office     -p "nixmac182-office-$DTS" -v ; \
        sudo nixos-rebuild boot   --flake /etc/nixos/#nixbook141           -p "nixbook141-$DTS" -v ;\
        sudo nixos-rebuild boot   --flake /etc/nixos/#nixbook141-console   -p "nixbook141-console-$DTS" -v ; \
        sudo nixos-rebuild boot   --flake /etc/nixos/#nixbook141-office    -p "nixbook141-office-$DTS" -v ; \
        sudo nixos-rebuild switch --flake "/etc/nixos/.#$HNAME"            -p "$HNAME-$DTS -v ; \
        sudo nixos-rebuild boot --install-bootloader '';
    };
    interactiveShellInit = ''
      ( cd && touch .zshrc .bashrc && uname -a )
    '';
    variables = {
      VISUAL = "vim";
      EDITOR = "vim";
      PAGER = "bat";
      SHELLCHECK_OPTS = "-e SC2086";
    };
  };
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

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    power-profiles-daemon.enable = true;
    thermald.enable = true;
    logind.hibernateKey = "ignore";
    opensnitch = {
      enable = true;
      settings = {
        firewall = "iptables"; # iptables or nftables
        defaultAction = "allow"; # allow or deny
      };
    };
    fstrim = {
      enable = true;
      interval = "daily";
    };
    journald.upload = {
      enable = false;
      settings = {
        Upload.URL = "https://192.168.0.250:19532";
        ServerKeyFile = "/etc/ca/client.key";
        ServerCertificateFile = "/etc/ca/client.pem";
        TrustedCertificateFile = "/etc/ca/journal-server.pem";
      };
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
