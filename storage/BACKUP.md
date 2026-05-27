# BACKUP AND RESTORE

## Restore FULL Server

### Restore ops, ops2 from last or snapshot
- connect new NVME via usb as device sda to your adminPC, move then to server, boot
```
cd /etc/nixos && TARGET=ops[1|2] make sda # assemble & restart server
cd && make ssh.ops[1|2]
sudo ssh -p 6623 me@ops[4|5| 'tar -C /mnt/tank/backup/[optional:.zfs/@snapshot]/ops[1|2] -cf - lib' | tar -C /var/lib -xvf -
sudo reboot 
```

### Restore ops[3|4|5] 
#### for optional ZFS storage see [ZFS.md](./ZFS.md)
- connect new NVME via usb as device sda to your adminPC, move then to server, boot, done
```
cd /etc/nixos && TARGET=ops[3|4|5] make sda # assemble & restart server
```

### Restore nextcloud from last week snapshot (similar for paperless and all other container)
```
cd && make ssh.ops2
sudo nixos-container stop nextcloud 
sudo mv -f /var/lib/container/nextcloud /var/lib/container/nextcloud.$(date '+%Y-%m-%dT%H:%M:%S')
sudo ssh -p 6623 me@ops[4|5| 'tar -C /mnt/tank/backup/ops2/lib/nixos-container/.zfs@<snapshot> -cf - nextcloud' | tar -C /var/lib/nixos-container -xvf -
sudo nixos-container start nextcloud 
```

## INFO: Automatic Backup Schedule 
- full automatic mode, no manual action needed
- backup.one=ops4
- backup.two=ops5
- automatic circular zfs backup schedule
    - snapshots: daily 22:15 full (concurrent, cross)
    - renetention: 7 days, 4 weeks, 4 month 
```
ops:Monday|ops:Wednesday|ops:Friday) TARGET=${infra.backup.one};;
ops:Tuesday|ops:Thursday) TARGET=${infra.backup.two};;
ops2:Monday|ops2:Wednesday|ops2:Thursday) TARGET=${infra.backup.two};;
ops2:Tuesday|ops2:Friday) TARGET=${infra.backup.one};;
```
