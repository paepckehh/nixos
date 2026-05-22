{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;

  zfsCompatibleKernelPackages =
    lib.filterAttrs (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name)
        != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;

  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    supportedFilesystems = infra.kernel.fs.server ++ ["zfs"];
    kernelPackages = lib.mkForce latestKernelPackage;
    zfs = {
      devNodes = "/dev/disk/by-id";
      forceImportAll = false;
      forceImportRoot = false;
      passwordTimeout = 0;
      extraPools = ["tank"];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus.exporters = {
      node.enabledCollectors = ["zfs"];
      smartctl.devices = lib.mkForce ["/dev/nvme0" "/dev/sda" "/dev/sdb" "/dev/sdc"];
    };
    fstrim = {
      enable = true;
      interval = "weekly";
    };
    zfs = {
      expandOnBoot = "all";
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
      autoSnapshot = {
        enable = true;
        daily = 7;
        hourly = 0;
        monthly = 6;
        weekly = 4;
        frequent = 0;
      };
      trim = {
        enable = true;
        interval = "weekly";
      };
    };
  };
}
