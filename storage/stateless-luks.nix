{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./stateless.nix];

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems."/nix".device = lib.mkForce "/dev/mapper/nix";

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
            device = "/dev/disk/by-diskseq/1-part3";
            allowDiscards = lib.mkForce true;
          };
        };
      };
    };
  };
}
