{
  config,
  lib,
  home-manager,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../mpaepcke.nix
    ../../user/desktop/unstable-me.nix
  ];
}
