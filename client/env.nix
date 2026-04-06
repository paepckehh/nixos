{
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./addrootCA.nix
    ./addCache.nix
  ];
  ###############
  #-= SYSTEM #=-#
  ###############
  system.stateVersion = "26.05";
}
