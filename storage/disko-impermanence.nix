{lib, ...}: {
  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = lib.mkForce {
    "/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
    };
    "/boot" = lib.mkForce {
      fsType = "vfat";
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
    "/nix" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/disk/by-partlabel/disk-main-nix";
      options = ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit"];
    };
    "/var" = lib.mkForce {
      device = "/nix/persist/var";
      fsType = "none";
      options = ["bind"];
    };
    "/home" = lib.mkForce {
      device = "/nix/persist/home";
      fsType = "none";
      options = ["bind"];
    };
    "/var/log" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
    };
    "/nix/var/log" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
    };
  };
  ###############
  #-=# DISKO #=-#
  ###############
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
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
            nix = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                mountOptions = ["noatime" "nodiratime" "discard" "commit=30" "nobarrier" "data=writeback" "journal_async_commit"];
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=80%"
        ];
      };
    };
  };
}
