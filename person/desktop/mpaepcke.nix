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
    ../mp.nix
    ../../user/desktop/me.nix
  ];
}
