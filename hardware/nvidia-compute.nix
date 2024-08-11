{
  config,
  lib,
  modulesPath,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [];

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    blacklistedKernelModules = ["nouveau" "nvidia" "nvidia_drm" "nvidia_modeset"];
    extraModulePackages = [pkgs.linuxPackages.nvidia_x11];
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [linuxPackages.nvidia_x11];
  };
}
