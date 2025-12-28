{
  config,
  pkgs,
  lib,
  ...
}: {
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    initrd.systemd.enable = lib.mkForce false;
  };
}
