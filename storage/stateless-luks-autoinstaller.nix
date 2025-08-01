{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./disko/stateless-luks-autoinstaller.nix];

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = ["aesni_intel" "applespi" "applesmc" "dm_mod" "cryptd" "intel_lpss_pci" "nvme" "mmc_block" "spi_pxa2xx_platform" "uas" "usbhid" "usb_storage" "xhci_pci"];
      luks = {
        mitigateDMAAttacks = lib.mkForce true;
        devices = {
          "nix" = {
            device = lib.mkForce "/dev/disk/by-diskseq/1-part3";
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
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      options = ["mode=755" "size=80%" "huge=within_size" "x-initrd.mount"];
    };
    "/nix" = lib.mkForce {
      device = "/dev/mapper/nix";
      fsType = "ext4";
      depends = ["/"];
      neededForBoot = true;
      options = ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit" "x-initrd.mount"];
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-diskseq/1-part1";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
  };
}
