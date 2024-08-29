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
            d = "dmesg --follow --human --kernel --userspace";
            c = "systemctl status chronyd ; chronyc tracking ; chronyc sources ; chronyc sourcestats ; sudo chronyc authdata ; sudo chronyc serverstats";
            man = "batman";
            slog = "journalctl --follow --priority=7 --lines=2500";
            cat = "bat --paging=never";
            termshark = "sudo termshark";
            bandwhich = "sudo bandwhich";
            ll = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
            la = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
            lt = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
            lo = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
            li = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
          };
          sessionVariables = {
            EDITOR = "vim";
            VISUAL = "vim";
            PAGER = "bat";
            SHELLCHECK_OPTS = "-e SC2086";
          };
          file = {".config/starship.toml".source = ./resources/starship/gruvbox-rainbow.toml;};
          packages = with pkgs; [
            asn
            age
            bandwhich
            bmon
            curlie
            dust
            dmidecode
            dnsutils
            fastfetch
            goaccess
            gobang
            git-crypt
            git-agecrypt
            httpie
            hyperfine
            shellcheck
            shfmt
            sysz
            tldr
            tailspin
            termdbms
            termshark
            tig
            tree
            trippy
            tz
            openssl
            kmon
            moreutils
            mtr
            nix-tree
            fastfetch
            fd
            jq
            oha
            openssl
            paper-age
            passage
            portal
            rage
            usbutils
            ugm
            vulnix
            yq
            xh
          ];
        };
        fonts.fontconfig.enable = true;
        programs = {
          btop.enable = true;
          direnv.enable = true;
          fzf.enable = true;
          thefuck.enable = true;
          starship.enable = true;
          go.enable = true;
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
            icons = true;
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
