{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7"; # start
        description = "me";
        uid = 1000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = ["wheel" "networkmanager" "audio" "input" "video" "docker" "libvirtd" "qemu-libvirtd" "rsync"];
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    users = {
      me = {
        home = {
          stateVersion = "24.11";
          enableNixpkgsReleaseCheck = false;
          homeDirectory = "/home/me";
          keyboard.layout = "us,de";
          shellAliases = {
            l = "ls -la";
            e = "vim";
            h = "htop --tree --highlight-changes";
            b = "btop";
            d = "sudo dmesg --follow --human --kernel --userspace";
            c = "systemctl status chronyd ; chronyc tracking ; chronyc sources ; chronyc sourcestats ; sudo chronyc authdata ; sudo chronyc serverstats";
            man = "batman";
            slog = "journalctl --follow --priority=7 --lines=2500";
            cat = "bat --paging=never";
            ollama-commit = "/home/me/.npm-packages/bin/ollama-commit -v -s --language en --api http://localhost:11434 --model mistral";
            tlm = "go run github.com/yusufcanb/tlm@latest $*";
            gollama = "go run github.com/sammcj/gollama@latest $*";
            gdu = "go run github.com/dundee/gdu@latest $i*";
            godap = "go run github.com/Macmod/godap@latest $i*";
            ll = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
            la = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
            lt = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
            lo = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
            li = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
            keybordlight1 = "echo 1 | sudo tee /sys/class/leds/input1::scrolllock/brightness";
          };
          sessionVariables = {
            EDITOR = "vim";
            VISUAL = "vim";
            PAGER = "bat";
            SHELLCHECK_OPTS = "-e SC2086";
          };
          file = {
            ".npmrc".text = ''prefix=~/.npm-packages'';
            ".config/starship.toml".source = ./resources/starship/gruvbox-rainbow.toml;
          };
          packages = with pkgs; [
            asn
            age
            bandwhich
            bmon
            binsider
            certgraph
            cifs-utils
            curlie
            ddgr
            dust
            dmidecode
            dnstracer
            dnsutils
            fastfetch
            goaccess
            gobang
            gopass
            git-crypt
            git-agecrypt
            gping
            gum
            httpie
            hyperfine
            inetutils
            shellcheck
            shfmt
            s-tui
            stress
            sysz
            tcping-go
            tldr
            tlsinfo
            termdbms
            termshark
            tshark
            tig
            tree
            trippy
            tz
            openssl
            parted
            progress
            pv
            kmon
            keepassxc
            keepassxc-go
            moreutils
            ncdu
            netscanner
            nix-tree
            nix-top
            nix-init
            nix-search-cli
            nix-output-monitor
            nixpkgs-review
            nix-prefetch-scripts
            nixfmt-rfc-style
            nixpkgs-fmt
            nvme-cli
            mongosh
            fastfetch
            fd
            jq
            paper-age
            passage
            pciutils
            pwgen
            rage
            rsync
            ssh-audit
            usbutils
            ugm
            webanalyze
            ventoy-full
            xh
            yamlfmt
            yarn
            yubikey-manager
            yq
          ];
        };
        fonts.fontconfig.enable = true;
        programs = {
          btop.enable = true;
          direnv.enable = true;
          fzf.enable = true;
          thefuck.enable = true;
          starship.enable = true;
          git.enable = true;
          gitui.enable = true;
          lazygit.enable = true;
          home-manager.enable = true;
          ripgrep.enable = true;
          skim.enable = true;
          atuin = {
            enable = true;
            flags = ["--disable-up-arrow"];
            settings = {
              auto_sync = false;
              dialect = "us"; # TODO
              update_check = false;
              sync_address = "http://localhost:8888"; # TODO
              sync_frequency = "10min";
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
          };
          fd = {
            enable = true;
            extraOptions = ["--absolute-path" "--no-ignore" "--hidden" "--ignore-case"];
          };
          gh = {
            enable = true;
            settings.git_protocol = "ssh";
          };
          go = {
            enable = true;
          };
          vim = {
            enable = true;
            defaultEditor = true;
            plugins = with pkgs.vimPlugins; [SudoEdit-vim vim-airline vim-shellcheck vim-go vim-git vim-nix];
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
    };
  };
}
