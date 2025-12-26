{lib, ...}: let
  disk.Id = {
    boot = "2489-EAAA";
    nix = "54185357-c42d-4817-9c8c-1be2b9e1c4ea";
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
