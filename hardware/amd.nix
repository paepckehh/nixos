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
    extraModulePackages = [config.boot.kernelPackages.zenpower];
    # kernelParams = [ "amd_pstate=active" "amd_iommu=force_isolation"];
    # kernelModules = [ "amd-pstate" "kvm-amd" ];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware.cpu.amd = {
    updateMicrocode = lib.mkForce true;
    ryzen-smu.enable = lib.mkForce true;
    sev.enable = lib.mkForce true;
  };
}
