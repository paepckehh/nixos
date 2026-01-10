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
}
