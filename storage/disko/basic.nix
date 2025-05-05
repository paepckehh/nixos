{
  config,
  disko,
  lib,
  ...
}: {
  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = lib.mkForce {
    "/" = {
      fsType = "ext4";
      device = "/dev/disk/by-partlabel/disk-main-root";
      options = ["noatime" "nodiratime" "discard"];
    };
    "/boot" = lib.mkForce {
      fsType = "vfat";
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
  };

  ###############
  #-=# DISKO #=-#
  ###############
  disko = {
    devices = {
      disk = {
        main = {
          device = "/dev/$DISKO_DEVICE_MAIN";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "1G";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              swap = {
                size = "8G";
                content = {
                  type = "swap";
                  randomEncryption = true;
                  priority = 50;
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
