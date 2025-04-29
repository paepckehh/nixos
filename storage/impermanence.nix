{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [ ./flakes/disko-impermanence.nix];

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  # options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
  # options = lib.mkForce ["mode=755" "noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit"];
  fileSystems = lib.mkForce {
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%"];
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
    "/nix" = lib.mkForce {
      device = lib.mkForce "/dev/disk/by-partlabel/disk-main-nix";
      fsType = lib.mkForce "ext4";
      options = lib.mkForce ["noatime" "nodiratime" "discard"];
    };
    "/var/lib" = lib.mkForce {
      device = "/nix/persist/var/lib";
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
    "/nix/var/log" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%"];
    };
  };
}
