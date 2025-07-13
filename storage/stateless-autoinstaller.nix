{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./disko/stateless-autoinstaller.nix];

  fileSystems = lib.mkForce {
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = ["mode=755" "size=80%" "huge=within_size" "x-initrd.mount"];
    };
    "/nix" = lib.mkForce {
      device = "/dev/disk/by-diskseq/1-part3";
      fsType = "ext4";
      depends = ["/"];
      neededForBoot = true;
      options = ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit" "x-initrd.mount"];
    };
    "/var/lib" = lib.mkForce {
      device = "/nix/persist/var/lib";
      fsType = "none";
      depends = ["/nix"];
      neededForBoot = true;
      options = ["bind" "x-initrd.mount"];
    };
    "/etc/ssh" = lib.mkForce {
      device = "/nix/persist/etc/ssh";
      fsType = "none";
      depends = ["/nix"];
      neededForBoot = true;
      options = ["bind" "x-initrd.mount"];
    };
    "/root/.ssh" = lib.mkForce {
      device = "/nix/persist/root/.ssh";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind" "x-initrd.mount"];
    };
    "/etc/nixos" = lib.mkForce {
      device = "/nix/persist/etc/nixos";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind"];
    };
    "/home" = lib.mkForce {
      device = "/nix/persist/home";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind"];
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-diskseq/1-part1";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
}
