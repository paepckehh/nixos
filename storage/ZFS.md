# ZFS

### info

see availible disks
''' 
ls -la /dev/disk/by-id
'''

### create tank 

'''
sudo zpool destroy tank > /dev/null 2>&1 # just in case ...
sudo zpool create -f -m legacy -o ashift=12 -o autotrim=on tank raidz ata-* # see ls -la /dev/disk/by-id output, do not include os disk
sudo zpool status -v 
sudo zpool list -v 
'''

### create tank/samba tank/backup

shared:
'''
sudo zfs set com.sun:auto-snapshot=true tank
sudo zfs set com.sun:auto-snapshot:frequent=false tank
sudo zfs set com.sun:auto-snapshot:hourly=true tank
sudo zfs set com.sun:auto-snapshot:daily=true tank
sudo zfs set com.sun:auto-snapshot:weekly=true tank
sudo zfs set com.sun:auto-snapshot:monthly=true tank
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
sudo zfs create -o mountpoint=legacy tank/backup
sudo zfs create -o mountpoint=legacy -o casesensitivity=insensitive tank/samba
sudo zfs list
'''
