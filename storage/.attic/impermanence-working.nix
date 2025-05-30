{
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = ["mode=755" "size=80%"];
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/nix" = {
    device = "/dev/sda3";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/nix/persist/home";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/var/lib" = {
    device = "/nix/persist/var/lib";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/etc/nixos" = {
    device = "/nix/persist/etc/nixos";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/etc/ssh" = {
    device = "/nix/persist/etc/ssh";
    fsType = "none";
    options = ["bind"];
  };
}
