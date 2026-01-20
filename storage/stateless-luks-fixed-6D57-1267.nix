{lib, ...}: let
  disk.Id = {
    boot = "6D57-1267";
    nix = "4bc6aeed-ea95-4d87-a4a0-5fa02204f005";
  };
in {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./stateless-luks.nix];

  ##############
  #-=# BOOT #=-#
  ##############
  boot.initrd.luks.devices."nix".device = lib.mkForce "/dev/disk/by-uuid/${disk.Id.nix}";

  ##################
  #-=# ZRAMSWAP #=-#
  ##################
  zramSwap.writebackDevice = lib.mkForce "/dev/disk/by-partlabel/disk-main-swap";

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems."/boot" = lib.mkForce {
    device = lib.mkForce "/dev/disk/by-uuid/${disk.Id.boot}";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };
}
