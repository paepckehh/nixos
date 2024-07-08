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
    ../user/me.nix
  ];

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        description = lib.mkDefault "PAEPCKE, Michael (me:env-admin)";
        initialHashedPassword = lib.mkDefault "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7";
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    users = {
      me = {
        home = {
          git = {
            userName = lib.mkDefault "PAEPCKE, Michael";
            userEmail = lib.mkDefault "git@github.com";
          };
        };
      };
    };
  };
}
