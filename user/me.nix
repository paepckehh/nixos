{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      "me" = {
        file = ../modules/resources/me.age;
        owner = "root";
        group = "wheel";
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.user.tmpfiles.rules = [
    "L /home/me/Mounts - - - - /var/run/user/60100/gvfs"
  ];

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        # initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7"; # start
        # initialHashedPassword = null; # lockdown, use smardcard only
        hashedPasswordFile = config.age.secrets."me".path;
        description = "me";
        uid = 60100;
        group = "me";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = ["users" "wheel" "backup" "networkmanager" "audio" "input" "video"];
        openssh.authorizedKeys.keys = lib.mkDefault ["ssh-ed25519 AAA-#locked#-"];
      };
    };
    groups.me = {
      gid = 60100;
      members = ["me"];
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    users = {
      me = {
        home = {
          stateVersion = config.system.nixos.release;
          enableNixpkgsReleaseCheck = false;
          homeDirectory = "/home/me";
          keyboard.layout = "us,de";
          sessionVariables = {
            # SSL_CERT_FILE = infra.pki.certs.rootCA.path;
            PAGER = "bat";
            EDITOR = "vim";
            STARSHIP_LOG = "error";
            CGO_ENABLED = "0";
          };
          shellAliases = {
            "man" = "batman";
            "cat" = "bat --paging=never";
          };
          file = {
            ".npmrc".text = ''prefix=~/.npm-packages'';
            ".config/starship.toml".source = ./resources/starship/gruvbox-rainbow.toml;
          };
        };
        fonts.fontconfig.enable = true;
        services.ssh-agent.enable = true;
        programs = {
          # btop.enable = true;
          # go.enable = true;
          home-manager.enable = true;
          git.enable = true;
          starship.enable = true;
          ripgrep.enable = true;
          delta = {
            enable = true;
            enableGitIntegration = true;
          };
          atuin = {
            enable = true;
            enableBashIntegration = false;
            enableFishIntegration = true;
            enableZshIntegration = true;
            flags = ["--disable-up-arrow"];
            settings = {
              auto_sync = false;
              dialect = "us";
              update_check = false;
              sync_address = "http://atuin.lan:8888";
              sync_frequency = "10min";
              sync.records = false;
              style = "full";
              secrets_filter = true;
              history_filter = ["LUKS" "genkey" "keygen" "private"];
            };
          };
          bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [batman batwatch];
          };
          eza = {
            enable = true;
            git = true;
            icons = "auto";
            extraOptions = ["--group-directories-first" "--header"];
            enableBashIntegration = false;
            enableFishIntegration = true;
            enableZshIntegration = true;
          };
          fd = {
            enable = true;
            extraOptions = ["--absolute-path" "--no-ignore" "--hidden" "--ignore-case"];
          };
          fzf = {
            enable = true;
            enableBashIntegration = false;
            enableFishIntegration = false;
            enableZshIntegration = false;
          };
          git = {
            settings = {
              init.defaultBranch = "main";
              user = {
                name = lib.mkDefault "me";
                email = lib.mkDefault "me@localhost";
              };
              protocol = lib.mkForce {
                file.allow = "always";
                git.allow = "never";
                ssh.allow = "always";
                http.allow = "never";
                https.allow = "always";
              };
              signing = {
                format = "ssh";
                signByDefault = lib.mkDefault false;
                key = lib.mkDefault "~/.ssh/id_ed25519.pub";
              };
            };
          };
          vim = {
            enable = true;
            defaultEditor = true;
            plugins = with pkgs.vimPlugins; [SudoEdit-vim vim-airline vim-shellcheck vim-git vim-nix];
            settings = {
              history = 10000;
              expandtab = true;
            };
            extraConfig = ''
              set hlsearch
              set nocompatible
              set nobackup
            '';
          };
          fish = {
            enable = true;
            interactiveShellInit = ''
              set fish_greeting # Disable greeting
              set fish_history "" # Disable history
              uname -a
            '';
          };
        };
      };
    };
  };
}
