{
  config,
  pkgs,
  lib,
  ...
}: {
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
          enable = true;
          name = "dracula"; # base16, catppuccin, dracula, github, gruvbox, mini-base16, nord, onedark, oxocarbon, rose-pine, tokyonight
          style = "darker"; # dark, darker, cool, deep, warm, warmer
        };
        viAlias = false;
        vimAlias = false;
        lsp.enable = true;
      };
    };
  };
}
