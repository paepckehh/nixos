{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# PROGRAMS #=-#
  ##################
  # requires nixvim flake
  programs = {
    nvf = {
      enable = true;
      vim = {
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
          };
          viAlias = false;
          vimAlias = false;
          lsp = {
            enable = true;
          };
        };
      };
    };
  };
}
