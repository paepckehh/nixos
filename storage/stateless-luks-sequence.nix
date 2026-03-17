{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./stateless-luks.nix];

  ##############
  #-=# BOOT #=-#
  ##############

  ##############
  #-=# BOOT #=-#
  ##############
  boot.initrd.luks.devices."nix" = {
    devices."nix".device = lib.mkForce "/dev/disk/by-diskseq/1-part3";
    allowDiscards = lib.mkForce true;
  };

  ##################
  #-=# ZRAMSWAP #=-#
  ##################
  zramSwap.writebackDevice = lib.mkForce "/dev/disk/by-diskseq/1-part2";

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems."/boot" = lib.mkForce {
    device = lib.mkForce "/dev/disk/by-diskseq/1-part1";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };
}
