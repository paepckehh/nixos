{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# NIXPKGS #=-#
  #################
  nix = {
    setting = {
      allowed-users = lib.mkForce ["@wheel" "nixbuilder"];
      extra-sandbox-paths = [config.programs.ccache.cacheDir];
    };
  };

  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs = {
    overlays = [
      (self: super: {
        ccacheWrapper = super.ccacheWrapper.override {
          extraConfig = ''
            export CCACHE_UMASK=007
            export CCACHE_MAXSIZE=25G
            export CCACHE_COMPRESSLEVEL=6
            export CCACHE_DIR="/var/cache/ccache"
            if [ ! -d "$CCACHE_DIR" ]; then
              echo "Directory '$CCACHE_DIR' does not exist! Please create it with: sudo mkdir -m0770 '$CCACHE_DIR' && sudo chown root:nixbld '$CCACHE_DIR'"
              exit 1
            fi
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami): Please verify its access permissions"
              exit 1
            fi
          '';
        };
      })
    ];
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    variables = {
      CCACHE_UMASK = "007";
      CCACHE_MAXSIZE = "25G";
      CCACHE_COMPRESSLEVEL = "6";
      CCACHE_DIR = "/var/cache/ccache";
    };
    shellAliases = {
      ccstat = "nix-ccache --show-stats && sudo nix-ccache --show-stats";
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      nixbuilder = {
        description = "sandboxed nixbuilder";
        uid = 64500;
        group = "users";
        createHome = true;
        isNormalUser = true;
        hashedPassword = null; # disable interactive authentication
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/K1rnyWsY0JapnE9wgz0lnbnkxhnN8lmNBOGp1iDpc nixbuilder@nix-build.lan"];
      };
    };
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    ccache = {
      enable = true;
      cacheDir = "/var/cache/ccache";
      packageNames = ["mongodb" "mongodb-5_0" "mongodb-6_0"];
    };
    ssh = {
      knownHosts = {
        nix-build = {
          extraHostNames = ["nix-build.lan"];
          publicKey = "";
        };
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [80 443];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    nix-serve = {
      enable = true;
      port = 5000;
      bindAddress = "127.0.0.1";
      openFirewall = true;
      secretKeyFile = "/var/cache-priv-key.pem";
      # sudo nix-store --generate-binary-cache-key nix-build.lan /var/cache-priv-key.pem /etc/nixos/server/resources/cache-pub-key.pem
    };
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "nix-build.lan" = {
          locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
        };
      };
    };
    prometheus.exporters.nginx = {
      enable = false;
    };
    endlessh-go = {
      enable = false;
      openFirewall = true;
      port = 22;
      listenAddress = "0.0.0.0";
      prometheus = {
        enable = false;
        port = 9119;
        listenAddress = "0.0.0.0";
      };
    };
    openssh = {
      enable = lib.mkForce true;
      allowSFTP = false;
      settings = {
        AllowUsers = ["nixbuilder"];
        AllowAgentForwarding = false;
        AllowStreamLocalForwarding = false;
        AllowTcpForwarding = false;
        AuthenticationMethods = "publickey";
        ChallengeResponseAuthentication = false;
        Ciphers = ["chacha20-poly1305@openssh.com"];
        KexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
        StrictModes = true;
        LogLevel = "INFO";
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        UseDns = false;
        UsePAM = true;
        X11Forwarding = false;
      };
      startWhenNeeded = true;
      hostKeys = [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
      ];
      openFirewall = true;
      listenAddresses = [
        {
          port = 22;
          addr = "0.0.0.0";
        }
      ];
    };
  };
}
