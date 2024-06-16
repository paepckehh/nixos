{ config, pkgs, lib, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes ";
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      persistent = false;
      dates = "daily";
      options = "--delete-older-than 28d";
    };
  };

  nixpkgs = { config.allowUnfree = true; };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.luks.devices."luks-018686c6-606a-4350-a90b-a146597dd207".device =
      "/dev/disk/by-uuid/018686c6-606a-4350-a90b-a146597dd207";
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  console = {
    earlySetup = true;
    useXkbConfig = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };

  system = {
    stateVersion = "24.05"; # do not touch
    autoUpgrade = {
      enable = true;
      persistent = true;
      flags = [ "--update-input" "nixpkgs" "--no-write-lock-file" "-L" ];
      dates = "hourly";
      randomizedDelaySec = "5min";
      allowReboot = false;
    };
  };

  hardware = {
    bluetooth.enable = lib.mkForce false;
    pulseaudio.enable = lib.mkForce false;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  time = {
    timeZone = "Europe/Berlin";
    hardwareClockInLocalTime = false; # RTC -> UTC
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  networking = {
    hostName = "nixos";
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    networkmanager.enable = true;
  };

  security = {
    auditd.enable = true;
    rtkit.enable = true;
    doas.enable = true;
    sudo.wheelNeedsPassword = lib.mkForce true;
    audit = {
      enable = true;
      rules = [ "-a exit,always -F arch=b64 -S execve" ];
    };
  };

  programs = {
    # GUI 
    firefox.enable = false;
    chromium.enable = false;
    ausweisapp.enable = false;
    evince.enable = false;
    evolution.enable = false;
    geary.enable = false;
    mepo.enable = false;
    steam.enable = false;
    system-config-printer.enable = false;
    nm-applet.enable = true;
    sniffnet.enable = true;
    tuxclocker.enable = true;
    virt-manager.enable = true;
    # Commandline
    cnping.enable = false;
    coolercontrol.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    direnv.enable = true;
    gnupg.agent.enable = false;
    htop.enable = true;
    iftop.enable = true;
    iotop.enable = true;
    java.enable = false;
    mosh.enable = false;
    mtr.enable = true;
    nano.enable = false;
    neovim.enable = false;
    nh.enable = true;
    nix-index.enable = false;
    screen.enable = true;
    starship.enable = false;
    tmux.enable = true;
    usbtop.enable = true;
    wireshark.enable = true;
    zmap.enable = true;
    # ... with config options
    ssh = {
      pubkeyAcceptedKeyTypes = [ "ssh-ed25519" "ssh-rsa" ];
      ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
      hostKeyAlgorithms = [ "ssh-ed25519" "ssh-rsa" ];
      kexAlgorithms = [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
      knownHosts.github = {
        extraHostNames = [ "github.com" ];
        publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };
    fzf.fuzzyCompletion = true;
    git = {
      enable = true;
      prompt.enable = true;
      config = {
        init.defaultBranch = "main";
        url = { "https://github.com/" = { insteadOf = [ "gh:" "github:" ]; }; };
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
      ohMyZsh.enable = false;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      alejandra
      curl
      gh
      jq
      kitty
      nixfmt-classic
      shellcheck
      shfmt
      tldr
      ripgrep
      moreutils
      yq
      yubikey-personalization
      vimPlugins.vim-nix
    ];
    shells = [ pkgs.bashInteractive pkgs.zsh ];
    shellAliases = {
      l = "ls -la";
      e = "vim";
      h = "htop --tree --highlight-changes";
      p = "sudo powertop";
      j = "journalctl -f";
      "nix.build" =
        "cd /etc/nixos && sudo nixfmt .* && sudo nix --verbose flake update && sudo nixos-rebuild --flake .#nixos --verbose --upgrade switch";
      "nix.push" =
        "cd /etc/nixos && sudo nixfmt *.nix && git reset && git add . && git commit -S -m update && git push --force";
      "dotenv.update" =
        "cd && ln -fs .dotenv/zshrc .zshrc && ln -fs .dotenv/bashrc .bashrc && ln -fs .dotenv/gitconfig .gitconfig";
      "dotenv.push" =
        "cd && cd .dotenv && git reset && git add . && git commit -S -m update && git push --force";
    };
    shellInit = "\n      eval $(ssh-agent)\n      touch .zshrc .bashrc\n    ";
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
      SHELLCHECK_OPTS = "-e SC2086";
    };
  };

  virtualisation = {
    containers.enable = false;
    containerd.enable = false;
    lxc.enable = false;
    xen.enable = false;
    vmware.host.enable = false;
    docker = {
      enable = false;
      enableOnBoot = false;
    };
    podman = {
      enable = false;
      dockerCompat = true;
    };
    lxd = {
      enable = false;
      ui.enable = true;
    };
    virtualbox.host = {
      enable = true;
      enableKvm = false;
    };
    libvirtd = {
      enable = true;
      onBoot = "start"; # ignore or start
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };
  };

  users = {
    users = {
      root = {
        hashedPassword = "!"; # disable root
      };
      me = {
        # initialPassword = "riot-bravo-charly-north"
        # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAA..." ];
        isNormalUser = true;
        description = "me";
        createHome = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" "networkmanager" "video" "docker" "vboxusers" ];
        packages = with pkgs; [
          go
          vimPlugins.vim-go
          hugo
          librewolf
          libreoffice
        ];
      };
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

  sound = { enable = false; };

  services = {
    avahi.enable = false;
    gnome.evolution-data-server.enable = lib.mkForce false;
    power-profiles-daemon.enable = true;
    thermald.enable = true;
    opensnitch.enable = true;
    xserver = {
      enable = true;
      xkb = {
        layout = "gb";
        variant = "";
      };
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
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
      hostKeys = [{
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }];
      listenAddresses = [{
        addr = "0.0.0.0";
        port = "8022";
      }];
    };
    cockpit = {
      enable = true;
      port = 9090;
      settings.WebService.AllowUnencrypted = false;
    };
    printing.enable = false;
    fstrim = {
      enable = true;
      interval = "daily";
    };
    pipewire = {
      enable = lib.mkForce false;
      alsa.enable = false;
      pulse.enable = false;
    };
  };

  # disable internal nvme & bt support 
  systemd = {
    services = {
      disable-nvme-d3cold = {
        enable = false;
        restartIfChanged = false;
      };
      btattach-bcm2e7c = {
        enable = false;
        restartIfChanged = false;
      };
      bluethooth = {
        enable = false;
        restartIfChanged = false;
      };
    };
  };
}
