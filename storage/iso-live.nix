{
  config,
  pkgs,
  lib,
  modulesPath,
  targetSystem,
  ...
}: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];
  isoImage = {
    edition = lib.mkForce "minimal";
    isoName = lib.mkForce "${config.isoImage.isoBaseName}-${targetSystem.config.networking.hostName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
    squashfsCompression = "zstd -Xcompression-level 19";
  };
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    initrd.systemd.enable = lib.mkForce false;
  };
}
