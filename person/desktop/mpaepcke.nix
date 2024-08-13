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
    ../../user/desktop/me.nix
  ];
}
