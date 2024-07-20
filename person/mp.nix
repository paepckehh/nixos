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
        description = lib.mkForce "PAEPCKE Michael env admin";
        initialHashedPassword = lib.mkForce "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7";
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
        programs = {
          git = {
            userName = lib.mkForce "PAEPCKE, Michael";
            userEmail = lib.mkForce "git@github.com";
          };
        };
      };
    };
  };

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-uuid/783b1348-9349-494a-819f-5dd80eb0976d";
      fsType = "ext4";
    };
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = ["aesni_intel" "cryptd"];
      luks = {
        mitigateDMAAttacks = lib.mkForce true;
        devices."luks-d23b5430-fff4-456e-a94f-951fb8ef6992".device = "/dev/disk/by-uuid/d23b5430-fff4-456e-a94f-951fb8ef6992";
      };
    };
  };
}
