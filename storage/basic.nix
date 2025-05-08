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
    "/boot" = lib.mkDefault {
      # alternative, but not always uniq: device = "/dev/disk/by-partlabel/disk-main-ESP";
      device = "/dev/disk/disk/by-diskseq/1-part1";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
    # always swap device [required, but not always in use] = "/dev/disk/disk/by-diskseq/1-part2"; skip swap
    "/" = lib.mkDefault {
      # alternative, but not always uniq: device = "/dev/disk/by-partlabel/disk-main-root";
      device = "/dev/disk/disk/by-diskseq/1-part3";
      fsType = "ext4";
      options = ["noatime" "nodiratime" "discard"];
    };
  };
}
