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
    kernelParams = ["amd_pstate=active"];
    kernelModules = ["amd-pstate" "amdgpu" "kvm-amd"];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    cpu.amd = {
      updateMicrocode = true;
      ryzen-smu.enable = true;
      sev.enable = true;
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services.tlp.settings = {
    RADEON_DPM_PERF_LEVEL_ON_AC = "low";
    RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
    RADEON_DPM_STATE_ON_AC = "battery";
    RADEON_DPM_STATE_ON_BAT = "battery";
    RADEON_POWER_PROFILE_ON_AC = "low";
    RADEON_POWER_PROFILE_ON_BAT = "low";
  };
}
