<div align="center">

# 💿 ZFS

**Two backup servers, RAIDZ pools, snapshots, scrub, trim and metadata warming.**

[![Pool](https://img.shields.io/badge/pool-tank-5277C3)](../storage/zfs.nix)
[![RAID](https://img.shields.io/badge/raid-RAIDZ-0891b2)](./ZFS.md)
[![Snapshots](https://img.shields.io/badge/snapshots-24h%20%2F%207d%20%2F%204w%20%2F%204m-0d9488)](../storage/zfs.nix)

`ssh -p 6623 me@ops4 'zpool status -v && zfs list'`

</div>

---

## 🚀 Overview

| Feature | `ops4` (primary) | `ops5` (secondary) |
|---|---|---|
| Role | Main backup target | Redundant backup target |
| Disks | 3× 4 TB (ST4000VN008) | 3× 6 TB (ST6000VN0033) |
| Pool | `tank` | `tank` |
| RAID | RAIDZ | RAIDZ |
| SSH | port `6623` | port `6623` |
| Datasets | `tank/backup`, `tank/samba` | `tank/backup` |

## 🏗️ Layout

```text
ops / ops2 ──rsync──► ops4 (backup.one) ──► /mnt/tank/backup/<host>
                   └► ops5 (backup.two) ──► /mnt/tank/backup/<host>
```

| Dataset | Mount | Owner | Notes |
|---|---|---|---|
| `tank` | `/mnt/tank` | root | Root dataset, `recordsize=1M`, `atime=off` |
| `tank/backup` | `/mnt/tank/backup` | `backup:backup` | rsync receive target, metadata warmed nightly |
| `tank/samba` | `/mnt/tank/samba` | `samba:samba` | Case-insensitive for Windows clients, metadata warmed frequently |

## ⚙️ Declarative config

[`storage/zfs.nix`](../storage/zfs.nix) is the source of truth for the NixOS
side: ZFS module, snapshot policy, timers and exporters.

```nix
boot.zfs = {
  devNodes = "/dev/disk/by-id";
  forceImportAll = false;
  forceImportRoot = false;
  passwordTimeout = 30;
};

services.zfs = {
  expandOnBoot = "all";
  autoScrub = { enable = true; interval = "weekly"; };
  trim = { enable = true; interval = "weekly"; };
  autoSnapshot = {
    enable = true;
    frequent = 0; hourly = 24;
    daily = 7; weekly = 4; monthly = 4;
  };
};
```

Dataset properties (`compress`, `recordsize`, `aclinherit`, `xattr`, `sync`,
`exec`, `devices`, `snapdir`) are applied with `zfs set` when a pool is created.
They are not declared in `zfs.nix`; keep the commands below as the record.

### Systemd timers

| Timer | Schedule | Purpose |
|---|---|---|
| `zfs-auto-snapshot.timer` | per retention policy | Hourly/daily/weekly/monthly snapshots |
| `zfs-auto-scrub.timer` | weekly | Detect silent corruption |
| `zfs-trim.timer` | weekly | TRIM for SSDs |
| `fstrim.timer` | weekly | Filesystem-level trim |
| `zfs-cache-meta-samba-timer` | `*:12`, `*:32`, `*:52` | Warm metadata on `tank/samba` |
| `zfs-cache-meta-backup-timer` | daily `22:55` | Warm metadata on `tank/backup` |

The metadata timers run `fd` over the datasets and discard output, which pulls
directory entries into the ARC.

## 📊 Monitoring

```bash
# Pool and datasets
ssh -p 6623 me@ops4 'zpool status -v && zfs list'
ssh -p 6623 me@ops5 'zpool status -v && zfs list'

# Snapshot inventory
ssh -p 6623 me@ops4 'zfs list -t snapshot -o name,creation,used'

# SMART
ssh -p 6623 me@ops4 'sudo smartctl --all /dev/sda'
```

`zfs.nix` also enables the Prometheus node `zfs` collector and SMART devices
`["/dev/nvme0" "/dev/sda" "/dev/sdb" "/dev/sdc"]`.

## 🔨 Recreate a pool

> Destructive. This erases every disk in the pool.

```bash
ls -la /dev/disk/by-id

# ops4
sudo zpool destroy tank
sudo zpool create -f -m /mnt/tank -o ashift=12 -o autotrim=on \
  tank raidz \
  ata-ST4000VN008-2DR166_ZM40X8TA \
  ata-ST4000VN008-2DR166_ZM40XDSE \
  ata-ST4000VN008-2DR166_ZM40XVH0

# ops5
sudo zpool create -f -m /mnt/tank -o ashift=12 -o autotrim=on \
  tank raidz \
  ata-ST6000VN0033-2EE110_ZAD9WLLC \
  ata-ST6000VN0033-2EE110_ZAD9WLED \
  ata-ST6000VN0033-2EE110_ZAD9T708
```

### Dataset properties

```bash
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
```

## 🔍 Troubleshooting

| Problem | Check | Fix |
|---|---|---|
| Pool won't import | `zpool status`, `zpool import` | Verify `/dev/disk/by-id` links |
| Scrub takes long | `zpool status` | Normal for large RAIDZ |
| ARC pressure | `zpool list`, `arc_summary` | Set `zfs.zfs_arc_max` if needed |
| Degraded pool | `zpool status -v` | `zpool replace tank <old> <new>` |
| Snapshots fill the pool | `zfs list -t snapshot` | Destroy old snapshots deliberately |
| Trim not running | `systemctl status zfs-trim.timer` | Requires `autotrim=on` at creation |

## 📁 Key paths

| Path | Purpose |
|---|---|
| `storage/zfs.nix` | Declarative ZFS config and timers |
| `storage/backup.nix` | rsync target configuration |
| `server/storage/zdash.nix` | ZFS dashboard module |
| `/mnt/tank/backup` | Backup receive target |
| `/mnt/tank/samba` | Windows share storage |
| `/dev/disk/by-id` | Persistent device names |

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="./BACKUP.md">backup</a> · <a href="./README.md">storage</a></sub></p>
