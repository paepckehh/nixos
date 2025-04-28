{
  lib,
  pkgs,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    #  ../server/ollama.nix
  ];

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
        assistant.codecompanion-nvim = {
          enable = false;
          setupOpts = {
            opts.language = "English";
            strategies = {
              chat = {
                adapter = "ollama";
              };
              inline = {
                adapter = "ollama";
                kemaps = {
                  accept_change.n = "ga";
                  reject_change.n = "gr";
                };
              };
            };
          };
        };
        autocomplete = {
          enableSharedCmpSources = true;
          blink-cmp = {
            enable = false;
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
            enable = true; #
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
          enable = true; # XXX debug config
          linters_by_ft = {
            # go = ["gofmt"];
            # nix = ["alejandra"];
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
          # toggle on-demand
          clang.enable = true;
          css.enable = true;
          html.enable = true;
          lua.enable = true;
          sql.enable = true;
          python.enable = false;
          php.enable = false;
          rust.enable = false;
          java.enable = false;
          yaml.enable = true;
          zig.enable = false;
          bash = {
            enable = true;
            extraDiagnostics = {
              enable = true;
              types = ["shellcheck"];
            };
            format = {
              enable = true;
              type = "shfmt"; # shfmt
            };
            lsp = {
              enable = true;
              server = "bash-ls"; # bash-ls
            };
          };
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
        lsp = {
          # enable = true;
          formatOnSave = true;
          lightbulb.enable = false;
          lspkind.enable = true;
        };
        package = pkgs.neovim-unwrapped; #
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
            base01 = "#444444"; # Background ---
            base02 = "#D65D0E"; # Background --
            base03 = "#49A4F8"; # Background -
            base04 = "#444444"; # Foreground -
            base05 = "#888888"; # Foreground --
            base06 = "#BBBBBB"; # Foreground ---
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
        ui = {
          noice.enable = false;
          smartcolumn.enable = false;
          modes-nvim = {
            enable = true;
            setupOpts = {
              line_opacity.visual = 20.0;
              colors = {
                delete = "#F5C259";
                insert = "#78CCC5";
                visual = "#9745BE";
              };
            };
          };
        };
        utility = {
          icon-picker.enable = true;
          vim-wakatime.enable = false;
          yanky-nvim = {
            enable = true;
            setupOpts = {
              history_length = "100"; # number of clips
              # storage = "sqlite"; # XXX debug
              system_clipboard.sync_with_ring = true;
            };
          };
        };
        viAlias = false;
        vimAlias = false;
      };
    };
  };
}
