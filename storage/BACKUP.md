# BACKUP

## Automatic Backup Schedule
- backup.one=ops4
- backup.two=ops5
- automatic circular zfs backup schedule
    - snapshots: daily 22:15 full (concurrent, cross)
    - renetention: 7 days, 4 weeks, 4 month 
'''
ops:Monday|ops:Wednesday|ops:Friday) TARGET=${infra.backup.one};;
ops:Tuesday|ops:Thursday) TARGET=${infra.backup.two};;
ops2:Monday|ops2:Wednesday|ops2:Thursday) TARGET=${infra.backup.two};;
ops2:Tuesday|ops2:Friday) TARGET=${infra.backup.one};;
'''

## Restore Full Server

### Restore ops[1|2] 
'''
# connect new NVME via usb as device sda to your adminPC, move then to server, boot
cd /etc/nixos && TARGET=ops[1|2] make sda 
# ssh into new ops 
cd && ssh.ops[1|2]
# full restore /var/lib
sudo ssh -p 6623 me@ops[4|5| 'tar -cf - /mnt/tank/backup/ops[1|2]' | tar -C / -cf -
sudo reboot 
'''

# Restore ops[3|4|5] 
'''
# connect new NVME via usb as device sda to your adminPC, move then to server, boot
# for optional ZFS storage see ZFS.md
cd /etc/nixos && TARGET=ops[3|4|5] make sda 
'''
