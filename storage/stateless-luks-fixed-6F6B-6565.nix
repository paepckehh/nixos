{lib, ...}: let
  disk.Id = {
    boot = "6F6B-6565";
    nix = "43dee7e1-ecad-4b77-b965-e7fbbeac665c";
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
