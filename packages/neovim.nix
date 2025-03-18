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
      settings.vim = {
        autocomplete = {
          enableSharedCmpSources = true;
          blink-cmp = {
            enable = false; # XXX currently broken
            friendly-snippets.enable = true;
            mappings = {
              complete = "<C-Space>";
              confirm = "<CR>";
              next = "<Tab>";
              previous = "<S-Tab>";
              close = "<C-e>";
              scrollDocsUp = "<C-d>";
              scrollDocsDown = "<C-f>";
            };
            setupOpts.cmdline = {
              keymap.preset = "none";
              completion.menu.auto_show = true;
            };
            sourcePlugins = {
              emoji.enable = true;
              ripgrep.enable = true;
              spell.enable = true;
            };
          };
          nvim-cmp = {
            enable = true; # XXX fallback for blink-cmp
            mappings = {
              complete = "<C-Space>";
              confirm = "<CR>";
              next = "<Tab>";
              previous = "<S-Tab>";
              close = "<C-e>";
              scrollDocsUp = "<C-d>";
              scrollDocsDown = "<C-f>";
            };
          };
        };
        autopairs.nvim-autopairs.enable = true;
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
          };
        };
        dashboard.startify = {
          enable = true;
          changeToDir = true;
          bookmarks = [
            {"f" = "/etc/nixos/flake.nix";}
            {"c" = "/etc/nixos/configuration.nix";}
            {"v" = "/etc/nixos/packages/neovim.nix";}
          ];
        };
        diagnostics.nvim-lint = {
          enable = false; # XXX debug config
          linters_by_ft = {
            markdown = ["vale"];
            text = ["vale"];
            go = ["gofmt"];
            nix = ["alejandra"];
          };
        };
        enableLuaLoader = true;
        filetree.neo-tree = {
          enable = true;
        };
        filetree.nvimTree = {
          enable = false;
          mappings = {
            toggle = "<leader>t";
            refresh = "<leader>tr";
            findFile = "<leader>tg";
            focus = "<leader>tf";
          };
        };
        statusline.lualine = {
          enable = true;
          theme = "onedark";
        };
        languages = {
          bash.enable = true;
          css.enable = true;
          html.enable = true;
          lua.enable = true;
          sql.enable = true;
          yaml.enable = true;
          python.enable = false;
          php.enable = false;
          rust.enable = false;
          java.enable = false;
          go = {
            enable = true;
            treesitter.enable = false;
            format = {
              enable = true;
              type = "gofmt"; # gofmt, gofumpt, golines
            };
            lsp = {
              enable = true;
              server = "gopls";
            };
          };
          markdown = {
            enable = true;
            format = {
              enable = true;
              type = "denofmt"; # denofmt, prettierd
            };
          };
          nix = {
            enable = true;
            treesitter.enable = false;
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
        package = pkgs.neovim-unwrapped; # pkgs.unstable.neovim-unwrappped
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
      };
    };
  };
}
