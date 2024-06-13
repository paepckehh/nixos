{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes ";
    gc = {
      automatic = true;
      persistent = false;
      dates = "daily";
      options = "--delete-older-than 28d";
    };
  };

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
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };

  system = {
    stateVersion = "24.05"; # do not touch
    autoUpgrade = {
      enable = true;
      persistent = true;
      flags = [ "--update-input" "nixpkgs" "--no-write-lock-file" "-L" ];
      dates = "daily";
      randomizedDelaySec = "25min";
      allowReboot = false;
    };
  };

  zramSwap = { enable = true; };

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };

  networking = {
    # hostName = "nixos";
    firewall.enable = true;
    networkmanager.enable = true;
  };

  security = {
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [ "-a exit,always -F arch=b64 -S execve" ];
    };
    rtkit.enable = true;
  };

  time = { timeZone = "Europe/Berlin"; };

  hardware = { pulseaudio.enable = false; };

  programs = { firefox.enable = false; };

  nixpkgs = { config.allowUnfree = true; };

  environment = {
    systemPackages = with pkgs; [
      curl
      tmux
      zsh
      vim
      neovim
      git
      gh
      jq
      yq
      nixfmt-classic
      shellcheck
      shfmt
      tldr
      ripgrep
      coreutils
      moreutils
      fzf
      htop
      powertop
    ];
  };

  users = {
    users.me = {
      # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAA..." ];
      # hashedPassword = "$6$UDriFNbpd7Hrg7wP$tSiNkJ....";
      # initialPassword = "...."
      isNormalUser = true;
      description = "me";
      createHome = true;
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [ go hugo librewolf libreoffice ];
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
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    openssh = {
      enable = false;
      settings = {
        passwordAuthentication = false;
        allowSFTP = false;
        challengeResponseAuthentication = false;
        extraConfig = ''
          AllowTcpForwarding yes
          X11Forwarding no
          AllowAgentForwarding no
          AllowStreamLocalForwarding no
          AuthenticationMethods publickey '';
      };
    };
    printing.enable = true;
    fstrim.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = false;
      pulse.enable = false;
    };
    thermald.enable = true;
    power-profiles-daemon.enable = true;
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "powersave";
          turbo = "auto";
        };
      };
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
      # bluethooth = {
      #  enable = false;
      #  restartIfChanged = false;
      # };
    };
  };

}
