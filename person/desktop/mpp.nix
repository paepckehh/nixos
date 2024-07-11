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
    ../mpp.nix
    ../../user/desktop/me.nix
  ];
}
