{
  config,
  pkgs,
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
        uid = 1000;
        group = "me";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = ["wheel" "mongodb" "backup" "networkmanager" "audio" "input" "video" "docker" "libvirtd" "qemu-libvirtd" "rsync"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
    groups.me = {
      gid = 1000;
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
          shellAliases = {
            "l" = "ls -la";
            "n" = "cd /etc/nixos && ls -la";
            "h" = "htop --tree --highlight-changes";
            "log.boot" = "sudo dmesg --follow --human --kernel --userspace";
            "log.system" = "sudo journalctl --follow --priority=7 --lines=2500";
            "log.time" = "systemctl status chronyd ; chronyc tracking ; chronyc sources ; chronyc sourcestats ; sudo chronyc authdata ; sudo chronyc serverstats";
            "b" = "btop";
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
          sessionVariables = {
            PAGER = "bat";
            STARSHIP_LOG = "error";
            SHELLCHECK_OPTS = "-e SC2086";
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
          thefuck.enable = true;
          starship.enable = true;
          ripgrep.enable = true;
          skim.enable = true;
          nushell.enable = true;
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
              sync_address = "http://localhost:8888";
              sync_frequency = "10min";
              theme.name = "";
            };
          };
          bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [batman batgrep batwatch];
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
            userName = "me";
            userEmail = "me@intra.lan";
            signing = {
              signByDefault = false;
              key = "~/.ssh/id_ed25519_sk.pub";
            };
            extraConfig = {
              init.defaultBranch = "main";
              gpg.format = "ssh";
              protocol = {
                allow = "always";
                file.allow = "always";
                git.allow = "always";
                ssh.allow = "always";
                http.allow = "always";
                https.allow = "always";
              };
            };
          };
          go = {
            enable = true;
          };
          ssh = {
            enable = true;
            addKeysToAgent = "yes";
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
               let commentTextMap = {
                   \'c': '\/\/',
                   \'h': '\/\/',
                   \'cpp': '\/\/',
                   \'java': '\/\/',
                   \'php': '\/\/',
                   \'javascript': '\/\/',
                   \'go': '\/\/',
                   \'python': '#',
                   \'sh': '#',
                   \'vim': '"',
                   \'make': '#',
                   \'conf': '#',
                   \'nix': ' #',
              \}
              noremap <silent> <expr> <F12> ((synIDattr(synID(line("."), col("."), 0), "name") =~ 'comment\c') ? ':<S-Right>:s/^\([ \t]*\)' . get(commentTextMap, &filetype, '#') . '/\1/<CR>' : ':<S-Right>:s/^/' . get(commentTextMap, &filetype, '#') . '/<CR>:nohl<CR>') . ':nohl<CR>:call histdel("/", -1)<CR>'
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
            enable = true;
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
