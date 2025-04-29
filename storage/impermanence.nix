{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./flakes/disko-impermanence.nix
  ];

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = lib.mkForce {
    "/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
    "/nix" = lib.mkForce {
      device = lib.mkForce "/dev/disk/by-partlabel/disk-main-nix";
      fsType = lib.mkForce "ext4";
      options = lib.mkForce ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit"];
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
    "/etc/ssh" = lib.mkForce {
      device = "/nix/persist/etc/ssh";
      fsType = "none";
      options = ["bind"];
    };
    "/var/log" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
    };
    "/nix/var/log" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
    };
  };
}
