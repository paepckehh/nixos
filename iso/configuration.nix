{
  config,
  disko,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
  ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  console = {
    earlySetup = true;
    font = "ter-v16n";
    packages = [pkgs.terminus_font];
  };
  services.getty.autologinUser = "root";
  users.users.root.initialHashedPassword = "";
  system.stateVersion = "24.11";
  disko.devices = {
    disk = {
      main = {
        device = "/dev/$DISKO_DEVICE_MAIN";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 100;
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
