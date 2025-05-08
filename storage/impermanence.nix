{
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [./disko/impermanence-autoinstaller.nix];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/disk/by-diskseq/1-part1";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/disk/by-diskseq/1-part3";
    fsType = "ext4";
    options = ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit"];
  };
  fileSystems."/var/lib" = {
    device = "/nix/persist/var/lib";
    fsType = "none";
    options = ["bind" "x-initrd.mount"];
  };
  fileSystems."/etc/ssh" = {
    device = "/nix/persist/etc/ssh";
    fsType = "none";
    options = ["bind" "x-initrd.mount"];
  };
  fileSystems."/home" = {
    device = "/nix/persist/home";
    fsType = "none";
    options = ["bind"];
  };
  fileSystems."/etc/nixos" = {
    device = "/nix/persist/etc/nixos";
    fsType = "none";
    options = ["bind"];
  };
}
