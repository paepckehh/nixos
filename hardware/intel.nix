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
      # "intel_iommu=strict"
    ];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware.cpu.intel = {
    updateMicrocode = lib.mkForce true;
    sgx.provision.enable = lib.mkForce false;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    tlp = {
      settings = {
        WOL_DISABLE = lib.mkForce "Y";
        USB_AUTOSUSPEND = lib.mkForce "0";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = lib.mkForce "wifi wwan";
        CPU_SCALING_GOVERNOR_ON_AC = lib.mkForce "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = lib.mkForce "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = lib.mkForce "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkForce "balance_power";
        PLATFORM_PROFILE_ON_AC = lib.mkForce "performance";
        PLATFORM_PROFILE_ON_BAT = lib.mkForce "balanced";
        INTEL_GPU_POWER_PROFILE_ON_AC = lib.mkForce "base";
        INTEL_GPU_POWER_PROFILE_ON_BAT = lib.mkForce "power_saving";
        INTEL_GPU_POWER_PROFILE_ON_SAV = lib.mkForce "power_saving";
      };
    };
  };
}
