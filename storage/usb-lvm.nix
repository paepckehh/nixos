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
    "/boot" = lib.mkForce {
      fsType = "vfat";
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
    "/nix" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/usbpool/nix";
      options = ["noatime" "nodiratime" "discard"];
    };
    "/var" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/usbpool/var";
      options = ["noatime" "nodiratime" "discard"];
    };
    "/home" = lib.mkForce {
      fsType = "ext4";
      device = "/dev/usbpool/home";
      options = ["noatime" "nodiratime" "discard"];
    };
  };
}
