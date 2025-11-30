{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./stateless-luks.nix];

  ##############
  #-=# BOOT #=-#
  ##############
  boot.initrd.luks.devices."nix".device = lib.mkForce "/dev/disk/by-partlabel/disk-main-nix";

  ##################
  #-=# ZRAMSWAP #=-#
  ##################
  zramSwap.writebackDevice = lib.mkForce "/dev/disk/by-partlabel/disk-main-swap";

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems."/boot" = lib.mkForce {
    device = lib.mkForce "/dev/disk/by-partlabel/disk-main-ESP";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };
}
