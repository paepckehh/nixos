# ZFS

### info

see availible disks
''' 
ls -la /dev/disk/by-id
'''

### create tank 

'''
sudo zfs destroy tank/backup # just in case ...
sudo zpool destroy tank      # just in case ...
sudo zpool create -f -m /mnt/tank -o ashift=12 -o autotrim=on tank draid ata-ST4000VN008-2DR166_XXXXXXX ata-ST4000VN008-2DR166_XXXXXX ata-ST4000VN008-2DR166_XXXXXX
sudo zpool status -v 
sudo zpool list -v 
'''

### create tank/samba tank/backup

shared:
'''
sudo zfs destroy tank/samba  # just in case ...
sudo zfs destroy tank/backup # just in case ...
sudo zfs set com.sun:auto-snapshot=true tank
sudo zfs set com.sun:auto-snapshot:frequent=false tank
sudo zfs set com.sun:auto-snapshot:hourly=false tank
sudo zfs set aclinherit=passthrough tank
sudo zfs set acltype=posixacl tank
sudo zfs set xattr=sa tank
sudo zfs set atime=off tank 
sudo zfs set recordsize=1M tank 
sudo zfs set compress=zstd-4 tank
sudo zfs set sync=disabled tank
sudo zfs set exec=off tank
sudo zfs set devices=off tank
sudo zfs set snapdir=visible tank
sudo zfs create tank/backup
sudo zfs create -o casesensitivity=insensitive tank/samba
sudo zfs list
'''
