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
    ../../user/desktop/me.nix
    ../person/mpp.nix
  ];
}
