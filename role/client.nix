{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../alias/nixops.nix
    ../configuration.nix
    # ../server/adguard.nix
    ../server/blocky.nix
    ../server/chronyPublic.nix
  ];
}
