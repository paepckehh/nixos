{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    user = {
      description = "normal-user";
      initialHashedPassword = "$y$j9T$LHspGdWTX1m6WpLsN6xvH.$Ewnrv.azy5vko2dySQxtYZc2G3W5VpeIbhMBRxoO5TC";
      uid = 10000;
      group = "users";
      createHome = true;
      isNormalUser = true;
      useDefaultShell = true;
      extraGroups = ["video"];
      openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    users = {
      user = {
        home = {
          stateVersion = "24.05";
          username = "user";
          homeDirectory = "/home/user";
        };
        programs = {
          home-manager.enable = true;
        };
      };
    };
  };
}
