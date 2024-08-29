{
  config,
  lib,
  ...
}: {
  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-uuid/783b1348-9349-494a-819f-5dd80eb0976d";
      fsType = "ext4";
      options = ["noatime" "nodiratime" "discard"];
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
        devices = {
          "luks-d23b5430-fff4-456e-a94f-951fb8ef6992" = {
            device = "/dev/disk/by-uuid/d23b5430-fff4-456e-a94f-951fb8ef6992";
            allowDiscards = true;
          };
        };
      };
    };
  };
}
