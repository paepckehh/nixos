{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./disko/impermanence-autoinstaller.nix];

  fileSystems = lib.mkForce {
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-diskseq/1-part1";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/nix" = lib.mkForce {
      device = "/dev/disk/by-diskseq/1-part3";
      fsType = "ext4";
      options = ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit"];
    };
    "/var/lib" = lib.mkForce {
      device = "/nix/persist/var/lib";
      fsType = "none";
      options = ["bind" "x-initrd.mount"];
    };
    "/etc/ssh" = lib.mkForce {
      device = "/nix/persist/etc/ssh";
      fsType = "none";
      options = ["bind" "x-initrd.mount"];
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
  };
}
