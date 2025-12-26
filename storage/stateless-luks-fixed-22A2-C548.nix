{lib, ...}: let
  disk.Id = {
    boot = "22A2-C548";
    nix = "40280f93-76a9-4232-9b65-8c70acee8de9";
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
