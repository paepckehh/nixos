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
  ssh.key = "/nix/persist/home/backup/.ssh/id_ed25519";
in {
  #####################
  #-=# FILESYSTEMS #=-#
  #####################
  fileSystems."/mnt/ro/var" = {
    device = "/nix/persist/var";
    fsType = "none";
    options = lib.mkForce ["bind" "ro" "noexec" "nosuid" "nodev"];
    neededForBoot = false;
  };
  ##############
  #-=# USER #=-#
  ##############
  users = {
    users = {
      backup = {
        createHome = true;
        uid = infra.backup.uid;
        isNormalUser = true;
        isSystemUser = false;
        group = "backup";
        hashedPassword = lib.mkForce "$y$j9T$YMyUhScE6LiNjm4XIxHKp/$LZLms7WzjfyK3USuEX3MFf.NHcDDkXkJafZhY96Oaa4"; # disable password login
        openssh.authorizedKeys.keys = [''command="${pkgs.rrsync}/bin/rrsync /mnt/tank/backup/",restrict ${infra.backup.sshKey}''];
      };
      samba = {
        createHome = true;
        uid = infra.samba.uid;
        isNormalUser = true;
        isSystemUser = false;
        group = "samba";
        hashedPassword = lib.mkForce null;
        openssh.authorizedKeys.keys = [''ssh-ed25519 ***locked**''];
      };
    };
    groups = {
      backup.gid = infra.backup.uid;
      samba.gid = infra.samba.uid;
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    services."rsync-backup" = {
      description = "rsync-backup";
      serviceConfig = {
        User = "root";
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/rsync-backup.sh";
      };
    };
    timers."rsync-backup-timer" = {
      description = "resync-backup-timer";
      wantedBy = ["timers.target"];
      timerConfig = {
        Unit = "rsync-backup.service";
        Persistent = false;
        OnCalendar = "*-*-* 23:15:00";
      };
    };
    tmpfiles.rules = [
      "d /mnt/tank/backup 0770 backup backup"
      "d /mnt/tank/samba  0770 samba samba"
      "d /var/run/backup  0770 root wheel"
    ];
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [rsync rrsync];
    etc."scripts/rsync-backup.sh".text = ''
      #!/bin/sh
      if [ "$EUID" -ne 0 ]; then echo "Backup-rsync: please run this script as root!" && exit 1 ; fi
      STATE=/var/run/backup
      /run/current-system/sw/bin/mkdir -p $STATE
      if [ -e $STATE/global.up ]; then echo "Rsync-Backup: global lock, exit" && exit 1; fi
      RM=/run/current-system/sw/bin/rm
      $RM $STATE/* >/dev/null 2>&1 || true
      TOUCH=/run/current-system/sw/bin/touch
      $TOUCH $STATE/global.up
      HOST="$(cat /etc/hostname)"
      DATE=/run/current-system/sw/bin/date
      WEEKDAY="$(LC_ALL=C $DATE '+%A')"
      TARGET=none
      case $HOST:$WEEKDAY in
      ops:Monday|ops:Wednesday|ops:Friday) TARGET="backup@${infra.backup.one}.adm.corp:$HOST";;
      ops:Tuesday|ops:Thursday) TARGET="backup@${infra.backup.two}.adm.corp:$HOST";;
      ops2:Monday|ops2:Wednesday|ops2:Thursday) TARGET="backup@${infra.backup.two}.adm.corp:$HOST";;
      ops2:Tuesday|ops2:Friday) TARGET="backup@${infra.backup.one}.adm.corp:$HOST";;
      esac
      $RM /var/lib/.last-backup.* >/dev/null 2>&1  || true
      $TOUCH /var/lib/.last-backup.startup."$( $DATE '+%Y-%m-%dT%H:%M:%S' )"
      if [ $TARGET != "none" ]; then
        KEY=${ssh.key}
        if [ ! -e $KEY ]; then echo "Backup-rsync: ssh rsync key not found: $KEY, exit" && exit 1 ; fi
        RSYNOPT="-a --checksum --delete --stats"
        SRC="/mnt/ro/var/lib"
        RSYNC=/run/current-system/sw/bin/rsync
        echo "Start Backup: /var/lib"
        $RSYNC $RSYNOPT -e "ssh -p 6623 -i $KEY" $SRC $TARGET || true
        echo "End Backup: /var/lib"
        NIXC=/run/current-system/sw/bin/nixos-container
        CLIST=$($NIXC list | grep -v '^$')
        for co in $CLIST; do
          echo "Start Backup: Container: $co"
          $NIXC stop $co
          $RSYNC $RSYNOPT -e "ssh -p 6623 -i $KEY" $SRC/nixos-containers/$co $TARGET/lib/nixos-containers/$co || true
          $NIXC start $co
          echo "End Backup: Container: $co"
        done
        $TOUCH /var/lib/.last-backup.finish."$( $DATE '+%Y-%m-%dT%H:%M:%S' )"
      else
        echo "Rsync-Backup: no action => $HOST:$WEEKDAY"
        $TOUCH /var/lib/.last-backup.finish-without-action."$( $DATE '+%Y-%m-%dT%H:%M:%S' )"
      fi
      $RM $STATE/* >/dev/null 2>&1 || true
      /run/current-system/sw/bin/sync
      /run/current-system/sw/bin/sync
      /run/current-system/sw/bin/sync
      exit 0
    '';
  };
}
