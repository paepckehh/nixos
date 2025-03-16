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
    };
  };
}
