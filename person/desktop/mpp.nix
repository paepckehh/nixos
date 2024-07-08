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
    ../../user/me-desktop.nix
    ../person/mpp.nix
  ];
}
