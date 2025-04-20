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
    "/" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/disk/by-partlabel/disk-main-root";
      options = ["noatime" "nodiratime" "discard"];
    };
    "/home" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/disk/by-partlabel/disk-main-home";
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
          device = "/dev/sdb";
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
              primary = {
                size = "100%";
                content = {
                  type = "lvm_pv";
                  vg = "mainpool";
                };
              };
            };
          };
        };
        lvm_vg = {
          mainpool = {
            type = "lvm_vg";
            lvs = {
              thinpool = {
                size = "100M";
                lvm_type = "thin-pool";
              };
              root = {
                size = "80M";
                lvm_type = "thinlv";
                pool = "thinpool";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = ["noatime" "nodiratime" "discard"];
                };
              };
              home = {
                size = "80M";
                lvm_type = "thinlv";
                pool = "thinpool";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/home";
                  mountOptions = ["noatime" "nodiratime" "discard"];
                };
              };
            };
          };
        };
      };
    };
  };
}
