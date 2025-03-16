{lib, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases.e = lib.mkForce "nvim";

  ##################
  #-=# PROGRAMS #=-#
  ##################
  # requires nvf input within flake.nix
  programs = {
    nvf = {
      enable = true;
      settings.vim = {
        comments.comment-nvim = {
          enable = true;
          mappings = {
            toggleCurrentLine = "gcc";
            toggleCurrentBlock = "gbc";
            toggleOpLeaderLine = "gc";
            toggleOpLeaderBlock = "gb";
            toggleSelectedLine = "gc";
            toggleSelectedBlock = "gb";
          };
          setupOpts.mappings = {
            basic = false;
            extra = false;
          };
        };
        dashboard.startify = {
          enable = true;
          changeToDir = true;
          bookmarks = [
            {"f" = "/etc/nixos/flake.nix";}
            {"c" = "/etc/nixos/configuration.nix";}
          ];
        };
        statusline.lualine = {
          enable = true;
          theme = "auto";
        };
        languages = {
          enableFormat = true;
          enableLSP = false;
          enableTreesitter = true;
          bash.enable = true;
          css.enable = true;
          html.enable = true;
          java.enable = true;
          lua.enable = true;
          markdown.enable = true;
          php.enable = true;
          python.enable = true;
          rust.enable = true;
          sql.enable = true;
          yaml.enable = true;
          go = {
            enable = true;
            format = {
              enable = true;
              type = "gofmt"; # gofmt, gofumpt, golines
            };
            lsp = {
              enable = true;
              server = "gopls";
            };
            treesitter.enable = true;
          };
          nix = {
            enable = true;
            treesitter.enable = true;
            extraDiagnostics = {
              enable = true;
              types = ["statix" "deadnix"];
            };
            format = {
              enable = true;
              type = "alejandra"; # alejandra, nixfmt
            };
            lsp = {
              enable = true;
              server = "nil"; # nil, nixd
            };
          };
        };
        spellcheck = {
          enable = true;
          languages = ["en" "de"];
          programmingWordlist.enable = true;
        };
        theme = {
          enable = false;
          name = "base16"; # base16, catppuccin, dracula, github, gruvbox, mini-base16, nord, onedark, oxocarbon, rose-pine, tokyonight
          style = ""; # theme specifig, eg: dark, darker, cool, deep, warm, warmer, day, night, colorblind
          base16-colors = {
            base00 = "#101600"; # Background ----
            base01 = "#1A1E01"; # Background ---
            base02 = "#242604"; # Background --
            base03 = "#2E2E05"; # Background -
            base04 = "#FFD129"; # Foreground -
            base05 = "#FFDA51"; # Foreground --
            base06 = "#FFE178"; # Foreground ---
            base07 = "#FFEBA0"; # Foreground ----
            base08 = "#EE2E00"; # Red
            base09 = "#EE8800"; # Orange
            base0A = "#EEBB00"; # Yellow
            base0B = "#63D932"; # Green
            base0C = "#3D94A5"; # Cyan
            base0D = "#5B4A9F"; # Blue
            base0E = "#883E9F"; # Purple
            base0F = "#A928B9"; # Magenta
          };
        };
        viAlias = false;
        vimAlias = false;
        lsp.enable = true;
      };
    };
  };
}
