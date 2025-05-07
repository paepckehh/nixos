{
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./disko/impermanence-autoinstaller.nix];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-ESP";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/disk-main-nix";
    fsType = "ext4";
    options = ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit"];
  };
}
