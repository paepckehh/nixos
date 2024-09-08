{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    # (modulesPath + "/hardware/network/broadcom-43xx.nix")
  ];

  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs = {
    config.allowUnfree = lib.mkDefault true;
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    # kernelParams = ["brcmfmac.feature_disable=0x82000"];
    # kernelParams = ["hid_apple.iso_layout=0"];
    # blacklistedKernelModules = ["b43" "bcma" "brcmfmac" "brcmsmac" "ssb"];
    blacklistedKernelModules = ["b43" "bcma" "brcmsmac" "ssb"];
    kernelParams = ["hid_apple.swap_opt_cmd=1"];
    # kernelModules = ["kvm-intel" "wl"];
    kernelModules = ["kvm-intel" "brcmfmac"];
    extraModulePackages = with config.boot.kernelPackages; [linux_latest_libre.broadcom_sta];
    initrd = {
      availableKernelModules = [
        "applespi"
        "applesmc"
        "spi_pxa2xx_platform"
        "intel_lpss_pci"
      ];
    };
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    enableAllFirmware = lib.mkForce true;
    facetimehd.enable = lib.mkForce false;
    graphics.extraPackages = with pkgs; [intel-vaapi-driver intel-ocl intel-media-driver];
    cpu = {
      intel = {
        updateMicrocode = lib.mkForce true;
        sgx.provision.enable = lib.mkForce false;
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    # enableB43Firmware = true;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mbpfan.enable = true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [libsmbios];
  };
}
