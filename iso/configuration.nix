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
  boot = {
    initrd = {
      systemd.enable = lib.mkForce false;
      availableKernelModules = ["applespi" "applesmc" "spi_pxa2xx_platform" "intel_lpss_pci" "ahci" "dm_mod" "sd_mod" "sr_mod" "nvme" "mmc_block" "uas" "usbhid" "usb_storage" "xhci_pci"];
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["page_alloc.shuffle=1" "amd_pstate=active"];
    kernelModules = ["vfat" "exfat" "uas" "kvm-intel" "kvm-amd" "amd-pstate"];
    readOnlyNixStore = lib.mkForce true;
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
      tmpfsSize = "85%";
    };
    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
    };
    kernel.sysctl = {
      "kernel.kptr_restrict" = lib.mkForce 2;
      "kernel.ftrace_enabled" = lib.mkForce false;
      "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkForce true;
      "net.ipv4.conf.all.accept_redirects" = lib.mkForce false;
      "net.ipv4.conf.all.secure_redirects" = lib.mkForce false;
      "net.ipv4.conf.default.accept_redirects" = lib.mkForce false;
      "net.ipv4.conf.default.secure_redirects" = lib.mkForce false;
      "net.ipv6.conf.all.accept_redirects" = lib.mkForce false;
    };
  };
  system = {
    stateVersion = "24.11"; # dummy target, do not modify
    switch.enable = true; # allow updates
  };
  time = {
    timeZone = null; # UTC, local: "Europe/Berlin";
    hardwareClockInLocalTime = true;
  };
  console = {
    earlySetup = lib.mkForce true;
    keyMap = "us";
    font = "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v18b.psf.gz";
    packages = with pkgs; [powerline-fonts];
  };
  swapDevices = [];
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  networking = {
    enableIPv6 = false;
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = true;
    };
  };
  hardware.enableAllFirmware = true;
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
                mountOptions = ["umask=0077"];
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
