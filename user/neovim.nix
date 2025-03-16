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
          bookmarks = {
            "f" = "/etc/nixos/flake.nix";
            "c" = "/etc/nixos/configuration.nix";
          };
        };
        viAlias = false;
        vimAlias = false;
        lsp.enable = true;
      };
    };
  };
}
