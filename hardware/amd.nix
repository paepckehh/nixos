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
    kernelModules = ["amd-pstate" "kvm-amd"];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware.cpu.amd = {
    updateMicrocode = lib.mkForce true;
    ryzen-smu.enable = lib.mkForce true;
    sev.enable = lib.mkForce true;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    tlp = {
      enable = true;
      settings = {
        WOL_DISABLE = lib.mkForce "Y";
        USB_AUTOSUSPEND = lib.mkForce "0";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = lib.mkForce "wifi wwan";
        START_CHARGE_THRESH_BAT0 = lib.mkForce 45;
        STOP_CHARGE_THRESH_BAT0 = lib.mkForce 85;
        CPU_SCALING_GOVERNOR_ON_AC = lib.mkForce "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = lib.mkForce "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = lib.mkForce "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkForce "balance_power";
        PLATFORM_PROFILE_ON_AC = lib.mkForce "performance";
        PLATFORM_PROFILE_ON_BAT = lib.mkForce "balanced";
        RADEON_DPM_PERF_LEVEL_ON_AC = lib.mkForce "auto";
        RADEON_DPM_PERF_LEVEL_ON_BAT = lib.mkForce "auto";
        RADEON_DPM_STATE_ON_AC = lib.mkForce "balanced";
        RADEON_DPM_STATE_ON_BAT = lib.mkForce "balanced";
      };
    };
  };
}
