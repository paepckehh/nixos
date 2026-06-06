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
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [../server/storage/zdash.nix];

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
      # extraPools = ["tank"];
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

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    tmpfiles.rules = [
      "d /mnt/tank/backup 0775 root wheel"
      "d /mnt/tank/samba 0775 root wheel"
    ];
    services = {
      zfs-mount.enable = lib.mkForce true;
      "zfs-cache-meta-samba" = {
        description = "zfs samba metadata cache";
        serviceConfig = {
          User = "root";
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/fd --quiet --hidden --no-ignore --threads 1 --base-directory /mnt/tank/samba > /dev/null 2>&1";
        };
      };
      "zfs-cache-meta-backup" = {
        description = "zfs backup metadata cache";
        serviceConfig = {
          User = "root";
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/fd --quiet --hidden --no-ignore --base-directory /mnt/tank/backup > /dev/null 2>&1";
        };
      };
    };
    timers = {
      "zfs-cache-meta-samba-timer" = {
        description = "git-mirror-cache-samba-timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          Unit = "zfs-cache-meta-samba.service";
          Persistent = false;
          OnCalendar = [
            "*-*-* *:12:00"
            "*-*-* *:32:00"
            "*-*-* *:52:00"
          ];
        };
      };
      "zfs-cache-meta-backup-timer" = {
        description = "zfs-cache-meta-backup-time";
        wantedBy = ["timers.target"];
        timerConfig = {
          Persistent = false;
          Unit = "zfs-cache-meta-backup.service";
          OnCalendar = ["*-*-* 22:55:00"];
        };
      };
    };
  };
}
