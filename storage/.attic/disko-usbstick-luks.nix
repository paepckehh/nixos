{
  config,
  disko,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = ["f2fs" "aesni_intel" "applespi" "applesmc" "dm_mod" "cryptd" "intel_lpss_pci" "nvme" "mmc_block" "spi_pxa2xx_platform" "uas" "usbhid" "usb_storage" "xhci_pci"];
      luks = {
        mitigateDMAAttacks = lib.mkForce true;
        devices = {
          "root" = {
            device = "/dev/disk/by-partlabel/disk-main-root";
            allowDiscards = true;
          };
        };
      };
    };
  };

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = lib.mkForce {
    "/" = {
      fsType = "f2fs";
      device = "/dev/mapper/root";
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
                  initrdUnlock = true;
                  name = "root";
                  type = "luks";
                  passwordFile = "/tmp/luks";
                  settings.allowDiscards = true;
                  extraFormatArgs = [
                    "--type luks2"
                    "--cipher aes-xts-plain64"
                    "--pbkdf argon2id"
                    "--iter-time 5000"
                  ];
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
  };
}
