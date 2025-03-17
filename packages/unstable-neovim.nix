{
  lib,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases.e = lib.mkForce "nvim";

  ##################
  #-=# PROGRAMS #=-#
  ##################
  # requires nvf.nix input within flake.nix
  programs = {
    nvf = {
      enable = true;
      packages = pkgs.unstable.neovim-unwrapped;
      settings.vim = {
        autocomplete = {
          blink-cmp = {
            enable = true;
          };
        };
        comments = {
          comment-nvim = {
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
          theme = "onedark";
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
            treesitter.enable = true;
            format = {
              enable = true;
              type = "gofmt"; # gofmt, gofumpt, golines
            };
            lsp = {
              enable = true;
              server = "gopls";
            };
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
        lineNumberMode = "relNumber"; # number, relNumber, none
        spellcheck = {
          enable = false;
          languages = ["en" "de"];
          programmingWordlist.enable = true;
        };
        theme = {
          enable = true;
          name = "base16"; # base16, catppuccin, dracula, github, gruvbox, mini-base16, nord, onedark, oxocarbon, rose-pine, tokyonight
          style = ""; # theme specifig, eg: dark, darker, cool, deep, warm, warmer, day, night, colorblind
          base16-colors = {
            base00 = "#000000"; # Background ----
            base01 = "#111111"; # Background ---
            base02 = "#D65D0E"; # Background --
            base03 = "#49A4F8"; # Background -
            base04 = "#444444"; # Foreground -
            base05 = "#AAAAAA"; # Foreground --
            base06 = "#FFFFFF"; # Foreground ---
            base07 = "#FFFFFF"; # Foreground ----
            base08 = "#EC5357"; # Red
            base09 = "#FFA400"; # Orange
            base0A = "#F9DA6A"; # Yellow
            base0B = "#C0E17D"; # Green
            base0C = "#99faf2"; # Cyan
            base0D = "#49A4F8"; # Blue
            base0E = "#BF40BF"; # Purple
            base0F = "#A47DE9"; # Magenta
          };
        };
        viAlias = false;
        vimAlias = false;
        lsp.enable = true;
      };
    };
  };
}
