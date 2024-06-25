{
  config,
  pkgs,
  ...
}: {
  ###############
  #-=# USERS #=-#
  ###############

  users = {
    users = {
      mpp = {
        initialPassword = "start-riot-bravo-charly";
        isNormalUser = true;
        createHome = true;
        useDefaultShell = true;
        description = "PAEPCKE, Michael";
        extraGroups = ["wheel" "networkmanager" "video" "docker" "libvirt"];
        # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAA..." ];
      };
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
        username = "mpp";
        homeDirectory = "/home/mpp";
      };
    };
  };
}
