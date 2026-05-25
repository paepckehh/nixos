{lib, ...}: {
  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-diskseq/1-part1";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/nix" = {
      device = "/dev/disk/by-diskseq/1-part3";
      fsType = "ext4";
      depends = ["/"];
      neededForBoot = true;
      options = ["noatime" "discard" "commit=600" "nobarrier" "data=writeback" "journal_async_commit" "x-initrd.mount"];
    };
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = ["noatime" "mode=755" "size=80%" "huge=within_size" "x-initrd.mount"];
    };
    "/var/cache" = lib.mkForce {
      device = "/nix/persist/var/cache";
      fsType = "none";
      depends = ["/nix"];
      neededForBoot = true;
      options = ["bind" "noatime" "noexec" "nodev" "x-initrd.mount"];
    };
    "/var/lib" = lib.mkForce {
      device = "/nix/persist/var/lib";
      fsType = "none";
      depends = ["/nix"];
      neededForBoot = true;
      options = ["bind" "noatime" "x-initrd.mount"];
    };
    "/etc/ssh" = lib.mkForce {
      device = "/nix/persist/etc/ssh";
      fsType = "none";
      depends = ["/nix"];
      neededForBoot = true;
      options = ["bind" "noatime" "noexec" "nodev" "nosuid" "x-initrd.mount"];
    };
    "/root/.ssh" = lib.mkForce {
      device = "/nix/persist/root/.ssh";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind" "noatime" "noexec" "nodev" "nosuid" "x-initrd.mount"];
    };
    "/etc/nixos" = lib.mkForce {
      device = "/nix/persist/etc/nixos";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind" "noatime" "nodev"];
    };
    "/home" = lib.mkForce {
      device = "/nix/persist/home";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind" "noatime" "noexec" "nodev"];
    };
  };
}
