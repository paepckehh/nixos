{lib, ...}: let
  disk.Id = {
    boot = "2733-AD8A";
    nix = "d260f274-06f1-471a-b1a7-faac6d19e8d5";
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
