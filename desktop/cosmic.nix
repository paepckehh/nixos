{
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./shared.nix
  ];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    desktopManager.cosmic.enable = true;
  };
}
