{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [./disko/basic.nix];

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  # some minimum sane fallback defaults, details: see storage folder
  fileSystems = lib.mkDefault {
    "/" = {
      fsType = "ext4";
      device = "/dev/disk/by-partlabel/disk-main-root";
      options = ["noatime" "nodiratime" "discard"];
    };
    "/boot" = lib.mkDefault {
      fsType = "vfat";
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
  };
}
