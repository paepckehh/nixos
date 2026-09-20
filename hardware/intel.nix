{
  config,
  pkgs,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  #-=# boot #=-#
  ##############
  boot = {
    kernelModules = [
      "kvm-intel"
    ];
    kernelParams = [
      #  "intel_iommu=strict"
    ];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware.cpu.intel = {
    updateMicrocode = lib.mkForce true;
    sgx.provision.enable = lib.mkForce false;
  };
}
