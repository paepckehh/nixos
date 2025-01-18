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
    ../configuration.nix
    ../server/adguard.nix
    ../server/chronyPublic.nix
  ];
}
