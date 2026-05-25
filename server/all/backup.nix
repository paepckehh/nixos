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
in {
  ##############
  #-=# USER #=-#
  ##############
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
      hashedPassword = lib.mkForce "$y$j9T$YMyUhScE6LiNjm4XIxHKp/$LZLms7WzjfyK3USuEX3MFf.NHcDDkXkJafZhY96Oaa4"; # disable password login
      openssh.authorizedKeys.keys = [''ssh-ed25519 ***locked**''];
    };
  };
  groups = {
    backup.gid = infra.backup.uid;
    samba.gid = infra.samba.uid;
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
        OnCalendar = "*-*-* 22:15:00";
      };
    };
    tmpfiles.rules = [
      "d /mnt/tank/backup 0770 backup backup"
      "d /mnt/tank/samba  0770 samba samba"
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
      if [ ! -e /nix/persit/home/backup/id_ed25519 ]; then echo "Backup-rsync: ssh rsync key not found" && exit 1 ; fi
      TOUCH=/run/current-system/sw/bin/touch
      RM=/run/current-system/sw/bin/rm
      NIXC=/run/current-system/sw/bin/nixos-container
      STATE=/var/run/backup
      if [ -e $STATE/init ]; then echo "Rsync-Backup: init lockfile exists, backup running already" && exit 1; fi
      $TOUCH $STATE/init
      $NIXC start rsync-backup
      until [ -e $STATE/first.done ]; do sleep 1; done;
      if [ -e $STATE/exit ]; then echo "Rsync-Backup: nothing todo, exit" && exit 0; fi
      CLIST=$($NIXC list | grep -v '^rsync-backup$' | grep -v '^$')
      for c in $CLIST; do $NIXC stop "$c"; done
      until [ -e $STATE/done ]; do sleep 1; done;
      for c in $CLIST; do $NIXC start "$c"; done
      $NIXC stop rsync-backup >/dev/null 2>&1
      $RM $STATE/*
    '';
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.rsync-backup = {
    autoStart = false;
    ephemeral = true;
    privateNetwork = false;
    bindMounts = {
      "/etc/hostname".isReadOnly = true;
      "/var/lib".isReadOnly = true;
      "/var/run/backup".isReadOnly = false;
      "/nix/persist/home/backup/.ssh/id_ed25519".isReadOnly = true;
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      imports = [../client/env.nix];
      systemd.services."rsync-backup-container" = {
        description = "rsync-backup-container";
        serviceConfig = {
          after = ["sockets.target"];
          wants = ["sockets.target"];
          wantedBy = ["multi-user.target"];
          User = "root";
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/rsync-backup-container.sh";
        };
      };
      environment = {
        systemPackages = with pkgs; [rsync];
        etc."scripts/rsync-backup-container.sh".text = ''
          #!/bin/sh
          if [ "$EUID" -ne 0 ]; then echo "Please run this script as root!" && exit 1 ; fi
          EXCLUDE="--exclude='lib/containers' --exclude='lib/.attic' --exclude='lib/docker' --exclude='lib/nixos' --exclude='lib/nixos-containers'"
          RSYNC=/run/current-system/sw/bin/rsync
          TOUCH=/run/current-system/sw/bin/touch
          STATE=/var/run/backup
          HOST="$(cat /etc/hostname)"
          WEEKDAY="$(LC_ALL=C /run/current-system/sw/bin/date +'%A')"
          TARGET=none
          case $HOST:$WEEKDAY in
          ops:Monday|ops:Wednesday|ops:Friday) TARGET=${infra.backup.one};;
          ops:Tuesday|ops:Thursday) TARGET=${infra.backup.two};;
          ops2:Monday|ops2:Wednesday|ops2:Thursday) TARGET=${infra.backup.two};;
          ops2:Tuesday|ops2:Friday) TARGET=${infra.backup.one};;
          esac
          if [ $TARGET = "none"  ]; then echo "Rsync-Backup: no action => $HOST:$WEEKDAY" && $TOUCH $STATE/exit $TATE/first.done && exit 0; fi
          if [ -e $STATE/running ]; then echo "Rsync-Backup: lockfile exists, backup running already" && $TOUCH $STATE/exit $TATE/first.done && exit 1; fi
          $TOUCH $STATE/running
          $RSYNC -a --checksum --delete --dry-run -e "ssh -p 6623 -i /home/backup/.ssh/id_ed25519" $EXCLUDE /var/lib backup@$TARGET.adm.corp:$HOSTNAME
          $TOUCH $STATE/first.done
          until [ -e /var/run/backup/container.down ]; do sleep 1; done;
          $RSYNC -a --checksum --delete --dry-run -e "ssh -p 6623 -i /home/backup/.ssh/id_ed25519" /var/lib/nixos-containers backup@$TARGET.adm.corp:$HOSTNAME
          $TOUCH $STATE/done
          /run/current-system/sw/bin/poweroff
        '';
      };
    };
  };
}
