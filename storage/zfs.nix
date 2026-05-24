{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;

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
      passwordTimeout = 30;
    };
  };

  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  # fileSystems = {
  #  "/mnt/tank" = lib.mkForce {
  #    device = "zpool/tank";
  #    fsType = "zfs";
  #    options = ["zfsutil" "noatime" "noexec" "nodev" "nosuid"];
  #  };
  #};

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.zfs-mount.enable = lib.mkForce false;

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
        frequent = 0;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 4;
      };
      trim = {
        enable = true;
        interval = "weekly";
      };
    };
  };
}
