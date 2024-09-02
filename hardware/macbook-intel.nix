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
    (modulesPath + "/hardware/network/broadcom-43xx.nix")
  ];

  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    # kernelParams = ["brcmfmac.feature_disable=0x82000"];
    # kernelParams = ["hid_apple.iso_layout=0"];
    kernelParams = ["hid_apple.swap_opt_cmd=1"];
    kernelModules = ["kvm-intel"];
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
    facetimehd.enable = lib.mkForce false;
    graphics.extraPackages = with pkgs; [intel-vaapi-driver intel-ocl intel-media-driver];
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    enableB43Firmware = true;
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
