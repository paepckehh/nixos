{
  config,
  pkgs,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    # kernelParams = ["brcmfmac.feature_disable=0x82000" "hid_apple.iso_layout=0"];
    # blacklistedKernelModules = ["b43" "bcma" "brcmsmac" "brcmfmac" "ssb"];
    # extraModulePackages = with config.boot.kernelPackages; [broadcom_sta];
    kernelParams = ["hid_apple.swap_opt_cmd=0" "hid_apple.iso_layout=1" "intel_iommu=on"];
    initrd.availableKernelModules = [
      "applespi"
      "applesmc"
      "spi_pxa2xx_platform"
      "intel_lpss_pci"
      "kvm-intel"
      "thunderbolt"
    ];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    enableAllFirmware = lib.mkForce true;
    facetimehd.enable = lib.mkForce false;
    # graphics.extraPackages = with pkgs; [intel-vaapi-driver intel-ocl intel-media-driver];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services.mbpfan.enable = true;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [libsmbios];
    etc."libinput/local-overrides.quirks".text = ''
      [MacBook(Pro) SPI Touchpads]
      MatchName=*Apple SPI Touchpad*
      ModelAppleTouchpad=1
      AttrTouchSizeRange=200:150
      AttrPalmSizeThreshold=1100

      [MacBook(Pro) SPI Keyboards]
      MatchName=*Apple SPI Keyboard*
      AttrKeyboardIntegration=internal

      [MacBookPro Touchbar]
      MatchBus=usb
      MatchVendor=0x05AC
      MatchProduct=0x8600
      AttrKeyboardIntegration=internal
    '';
  };
}
