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
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["amd_pstate=active"];
    kernelModules = ["amd-pstate" "amdgpu"];
  };
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # sudo bootctl status
  # sudo fwupdmgr get-bios-setting --json
  environment = {
    etc."etc/fwupd/bios-settings.d".target = lib.mkForce ./bios-t640.json;
    systemPackages = [
      pkgs.sbctl
    ];
  };

  ##################
  #-=# HARDWARE #=-#
  ##################
  hardware = {
    amdgpu = {
      amdvlk.enable = lib.mkForce true;
    };
    enableAllFirmware = lib.mkForce true;
    enableAllHardware = lib.mkForce true;
    enableRedistributableFirmware = lib.mkForce true;
    cpu = {
      amd = {
        updateMicrocode = lib.mkForce true;
        ryzen-smu.enable = lib.Force true;
        sev.enable = lib.mkForce true;
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    tlp = {
      enable = true;
      settings = {
        USB_AUTOSUSPEND = "0";
        WOL_DISABLE = "Y";
        START_CHARGE_THRESH_BAT0 = 45;
        STOP_CHARGE_THRESH_BAT0 = 85;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        # WIFI_PWR_ON_AC = "on";
        # WIFI_PWR_ON_BAT = "on";
        # DEVICES_TO_ENABLE_ON_STARTUP = "bluetooth wifi wwan";
        # DEVICES_TO_ENABLE_ON_AC = "bluetooth wifi wwan";
        # DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "";
        # DEVICES_TO_DISABLE_ON_LAN_CONNECT = "";
        # DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "";
        # DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "";
        # DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "bluetooth wifi wwan";
        # DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT = "bluetooth wifi wwan";
        # DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT = "bluetooth wifi wwan";
        # DEVICES_TO_ENABLE_ON_UNDOCK = "bluetooth wifi wwan";
        # DEVICES_TO_DISABLE_ON_UNDOCK = "";
        # use tlp-stat for more details
      };
    };
  };
}
