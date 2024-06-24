{
  config,
  pkgs,
  ...
}: {
  ###############
  #-=# USERS #=-#
  ###############

  users = {
    me = {
      initialPassword = "start-riot-bravo-charly";
      isNormalUser = true;
      createHome = true;
      useDefaultShell = true;
      description = "me";
      extraGroups = ["wheel" "networkmanager" "video" "docker" "libvirt"];
      # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAA..." ];
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################

  home-manager = {
    users.me = {
      programs.home-manager.enable = true;
      home = {
        stateVersion = "24.05";
        username = "me";
        homeDirectory = "/home/me";
      };
    };
  };
}
