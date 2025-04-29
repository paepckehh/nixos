{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./flakes/disko-impermanence-luks.nix
  ];

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
            device = "/dev/disk/by-partlabel/disk-main-nix";
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
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
    };
    "/boot" = lib.mkForce {
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077" "defaults"];
    };
    "/nix" = lib.mkForce {
      device = lib.mkForce "/dev/mapper/nix";
      fsType = lib.mkForce "ext4";
      options = lib.mkForce ["noatime" "nodiratime" "discard" "commit=10" "nobarrier" "data=writeback" "journal_async_commit"];
    };
    "/var" = lib.mkForce {
      device = "/nix/persist/var";
      fsType = "none";
      options = ["bind"];
    };
    "/home" = lib.mkForce {
      device = "/nix/persist/home";
      fsType = "none";
      options = ["bind"];
    };
    "/etc/nixos" = lib.mkForce {
      device = "/nix/persist/etc/nixos";
      fsType = "none";
      options = ["bind"];
    };
    "/etc/ssh" = lib.mkForce {
      device = "/nix/persist/etc/ssh";
      fsType = "none";
      options = ["bind"];
    };
    "/var/log" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
    };
    "/nix/var/log" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "mode=755" "size=80%" "huge=within_size"];
    };
  };
}
