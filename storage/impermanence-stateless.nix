{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./disko/impermanence-autoinstaller.nix];

  fileSystems = lib.mkForce {
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = ["defaults" "mode=755" "size=80%" "huge=within_size" "x-initrd.mount"];
    };
    "/nix" = lib.mkForce {
      device = "/dev/disk/by-diskseq/1-part3";
      fsType = "ext4";
      depends = ["/"];
      neededForBoot = true;
      options = ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit" "x-initrd.mount"];
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-diskseq/1-part1";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
  };
}
