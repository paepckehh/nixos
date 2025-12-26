{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [./disko/stateless-luks.nix];

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
            device = lib.mkDefault "/dev/disk/by-diskseq/1-part3";
            allowDiscards = true;
          };
        };
      };
    };
  };

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems = {
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = ["mode=755" "size=80%" "huge=within_size" "x-initrd.mount"];
    };
    "/nix" = lib.mkForce {
      device = "/dev/mapper/nix";
      fsType = "ext4";
      depends = ["/"];
      neededForBoot = true;
      options = ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit" "x-initrd.mount"];
    };
    "/var/lib" = lib.mkForce {
      device = "/nix/persist/var/lib";
      fsType = "none";
      depends = ["/nix"];
      neededForBoot = true;
      options = ["bind" "x-initrd.mount"];
    };
    "/etc/ssh" = lib.mkForce {
      device = "/nix/persist/etc/ssh";
      fsType = "none";
      depends = ["/nix"];
      neededForBoot = true;
      options = ["bind" "x-initrd.mount"];
    };
    "/root/.ssh" = lib.mkForce {
      device = "/nix/persist/root/.ssh";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind" "x-initrd.mount"];
    };
    "/etc/nixos" = lib.mkForce {
      device = "/nix/persist/etc/nixos";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind"];
    };
    "/home" = lib.mkForce {
      device = "/nix/persist/home";
      fsType = "none";
      depends = ["/nix"];
      options = ["bind"];
    };
  };
}
