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
    "/etc/nixos" = lib.mkForce {
      device = "/nix/persist/etc/nixos";
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
}
