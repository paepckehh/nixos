# ZFS

## INFO

### get overview
```
echo "########## OPS4 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops4 'zpool status -v && zfs list'
echo "########## OPS5 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops5 'zpool status -v && zfs list'
```

### get more details 
``` 
echo "########## OPS4 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops4 'zpool status -v --json' | jq
ssh -p 6623 me@ops4 'zfs list --json' | jq
echo "########## OPS5 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops5 'zpool status -v --json' | jq
ssh -p 6623 me@ops5 'zfs list --json' | jq 
```

### get all details 
``` 
echo "########## OPS4 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops4 'zpool status -v --json' | jq
ssh -p 6623 me@ops4 'zfs list --json' | jq
ssh -p 6623 me@ops4 'zfs get all --json' | jq 
echo "########## OPS5 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops5 'zpool status -v --json' | jq
ssh -p 6623 me@ops5 'zfs list --json' | jq 
ssh -p 6623 me@ops5 'zfs get all --json' | jq 
```

### list all snapshots/usage only
``` 
echo "########## OPS4 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops4 'zfs list -t snapshot -o name,creation,used' 
echo "########## OPS5 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops5 'zfs list -t snapshot -o name,creation,used' 
```


## CREATE 

### list disks

see all disks
``` 
ls -la /dev/disk/by-id
```

### create tank

ops4
```
sudo zpool destroy tank > /dev/null 2>&1 # just in case ...
sudo zpool create -f -m /mnt/tank -o ashift=12 -o autotrim=on tank raidz ata-ST4000VN008-XXX ata-ST4000VN008-XXX ata-ST4000VN008-XXX
sudo zpool status -v 
sudo zpool list -v 
```

ops5:
```
sudo zpool destroy tank > /dev/null 2>&1 # just in case ...
sudo zpool create -f -m /mnt/tank -o ashift=12 -o autotrim=on tank raidz ata-ST6000VN0033-XXX ata-ST6000VN0033-XXX ata-ST6000VN0033-XX
sudo zpool status -v 
sudo zpool list -v
``` 

### create tank/samba tank/backup

shared:
```
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
sudo zfs create tank/backup
sudo zfs create -o casesensitivity=insensitive tank/samba
sudo zfs list
```
