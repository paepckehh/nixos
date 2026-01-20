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
    initrd.availableKernelModules = ["aesni_intel"];
    kernelModules = ["kvm-intel"];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    cpu.intel = {
      updateMicrocode = true;
      sgx.provision.enable = true;
    };
    intel-gpu-tools.enable = true;
    graphics.extraPackages = with pkgs; [intel-media-driver vpl-gpu-rt]; # intel-compute-runtime
  };
}
