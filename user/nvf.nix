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
      settings = {
        vim = {
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
