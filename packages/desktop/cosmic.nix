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
    displayManager.cosmic-greeter.enable = true;
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware.system76.enableAll = true;
}
