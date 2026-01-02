{
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./addrootCA.nix
    ./addCache.nix
    ./forward-syslog-ng.nix
  ];
  ###############
  #-= SYSTEM #=-#
  ###############
  system.stateVersion = "26.05";
}
