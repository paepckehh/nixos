{lib, ...}: {
  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = lib.mkForce {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=80%" "mode=755"];
    };
    "/var/log" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=80%" "mode=755"];
    };
    "/nix/var/log" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=80%" "mode=755"];
    };
    "/boot" = lib.mkForce {
      fsType = "vfat";
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
    "/nix" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/usbpool/nix";
      options = ["noatime" "nodiratime" "discard" "commit=30" "nobarrier" "data=writeback" "journal_async_commit"];
    };
    "/var" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/usbpool/var";
      options = ["noatime" "nodiratime" "discard" "commit=15" "data=writeback" "journal_async_commit"];
    };
    "/home" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/usbpool/home";
      options = ["noatime" "nodiratime" "discard" "commit=15" "data=writeback" "journal_async_commit"];
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
              primary = {
                size = "100%";
                content = {
                  type = "lvm_pv";
                  vg = "usbpool";
                };
              };
            };
          };
        };
      };
      lvm_vg = {
        usbpool = {
          type = "lvm_vg";
          lvs = {
            thinpool = {
              size = "100%";
              lvm_type = "thin-pool";
            };
            nix = {
              size = "256g";
              lvm_type = "thinlv";
              pool = "thinpool";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                mountOptions = ["noatime" "nodiratime" "discard"];
              };
            };
            home = {
              size = "256g";
              lvm_type = "thinlv";
              pool = "thinpool";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
                mountOptions = ["noatime" "nodiratime" "discard"];
              };
            };
            var = {
              size = "256g";
              lvm_type = "thinlv";
              pool = "thinpool";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var";
                mountOptions = ["noatime" "nodiratime" "discard"];
              };
            };
          };
        };
      };
    };
  };
}
