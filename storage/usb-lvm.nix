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
}
