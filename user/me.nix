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
        description = "minimal-env-admin";
        uid = 1000;
        group = "users";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = ["wheel" "networkmanager" "audio" "input" "video" "docker" "libvirtd" "qemu-libvirtd"];
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
          stateVersion = "24.05";
          username = "me";
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
            certinfo = "go run paepcke.de/certinfo/cmd/certinfo@latest $*";
            tlsinfo = "go run paepcke.de/tlsinfo/cmd/tlsinfo@latest $*";
            ll = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
            la = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
            lt = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
            lo = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
            li = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
            "service.log" = "journalctl --since='30 min ago' -u $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
            "service.start" = "sudo systemctl start $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
            "service.stop" = "sudo systemctl stop $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
            "service.restart" = "sudo systemctl restart $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
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
            opnborg
            asn
            age
            bandwhich
            bmon
            certgraph
            curlie
            dust
            dmidecode
            dnstracer
            dnsutils
            fastfetch
            filezilla
            goaccess
            gobang
            git-crypt
            git-agecrypt
            gping
            httpie
            hyperfine
            shellcheck
            shfmt
            socialscan
            sysz
            tea
            tldr
            tailspin
            termdbms
            termshark
            tshark
            tig
            tree
            trippy
            tz
            openssl
            kmon
            keepassxc
            keepassxc-go
            moreutils
            nodejs
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
            nodejs
            fastfetch
            fd
            jq
            oha
            openssl
            paper-age
            passage
            pciutils
            portal
            pwgen
            rage
            ssh-audit
            usbutils
            ugm
            webanalyze
            vulnix
            xh
            yamlfmt
            yarn
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
          gh-dash.enable = true;
          git.enable = true;
          gitui.enable = true;
          lazygit.enable = true;
          home-manager.enable = true;
          ripgrep.enable = true;
          skim.enable = true;
          atuin = {
            enable = true;
            flags = ["--disable-up-arrow"];
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
            extraOptions = ["--absolute-path" "--no-ignore"];
          };
          gh = {
            enable = true;
            settings.git_protocol = "ssh";
          };
          go = {
            enable = true;
          };
          neovim = {
            enable = true;
            plugins = with pkgs.vimPlugins; [go-nvim];
          };
          vim = {
            enable = true;
            defaultEditor = true;
            plugins = with pkgs.vimPlugins; [vim-shellcheck vim-go vim-git];
            settings = {
              expandtab = true;
              mousehide = false;
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
    };
  };
}
