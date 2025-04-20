{
  config,
  disko,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot.initrd.availableKernelModules = ["f2fs" "mmc_block" "sd_mod" "sr_mod" "uas" "usbhid" "usb_storage" "xhci_pci"];

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = lib.mkForce {
    "/" = {
      fsType = "f2fs";
      device = "/dev/disk/by-partlabel/disk-main-root";
      options = ["noatime" "nodiratime" "discard"];
    };
    "/boot" = lib.mkForce {
      fsType = "vfat";
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
  };

  ###############
  #-=# DISKO #=-#
  ###############
  disko = {
    devices = {
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
                  priority = 50;
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "f2fs";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
