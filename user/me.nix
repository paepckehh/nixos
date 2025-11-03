{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [];

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7"; # start
        description = "me";
        uid = 60100;
        group = "me";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = ["users" "wheel" "mongodb" "backup" "networkmanager" "audio" "input" "video" "docker" "libvirtd" "qemu-libvirtd" "rsync"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
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
            PAGER = "bat";
            STARSHIP_LOG = "error";
            SHELLCHECK_OPTS = "-e SC2086";
            EDITOR = "vim";
          };
          shellAliases = {
            "b" = "sudo btop";
            "d" = "sudo dmesg";
            "l" = "ls -la";
            "n" = "cd /etc/nixos && ls -la";
            "h" = "htop --tree --highlight-changes";
            "log.boot" = "sudo dmesg --follow --human --kernel --userspace";
            "log.system" = "sudo journalctl --follow --priority=7 --lines=2500";
            "log.time" = "systemctl status chronyd ; chronyc tracking ; chronyc sources ; chronyc sourcestats ; sudo chronyc authdata ; sudo chronyc serverstats";
            "man" = "batman";
            "cat" = "bat --paging=never";
            "time.status" = "timedatectl timesync-status";
            "keybordlight" = "echo 1 | sudo tee /sys/class/leds/input1::scrolllock/brightness";
            "ll" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
            "la" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
            "lg" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --group";
            "lt" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
            "lo" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
            "li" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
          };
          file = {
            ".npmrc".text = ''prefix=~/.npm-packages'';
            ".config/starship.toml".source = ./resources/starship/gruvbox-rainbow.toml;
          };
        };
        fonts.fontconfig.enable = true;
        services.ssh-agent.enable = true;
        programs = {
          btop.enable = true;
          home-manager.enable = true;
          git.enable = true;
          go.enable = true;
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
              auto_sync = true;
              dialect = "us";
              update_check = false;
              sync_address = "http://atuin.lan:8888";
              sync_frequency = "10min";
              sync.records = true;
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
          pay-respects = {
            enable = true;
            enableBashIntegration = false;
            enableFishIntegration = true;
            enableZshIntegration = true;
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
          zsh = {
            enable = false;
            autocd = true;
            autosuggestion.enable = true;
            defaultKeymap = "viins";
            syntaxHighlighting.enable = true;
            historySubstringSearch.enable = true;
            history = {
              save = 0;
              saveNoDups = true;
              path = "/dev/null";
              share = false;
              extended = true;
              ignoreSpace = true;
            };
          };
        };
      };
    };
  };
}
