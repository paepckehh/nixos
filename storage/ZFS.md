# 💿 ZFS

> The dual-server ZFS backup fleet — two hosts (ops4 + ops5), ZFS RAIDZ with 4–6 TB drives, daily/weekly/monthly snapshots, auto-trim, and full declarative config via NixOS.

---

## 🚀 Overview

| Feature | ops4 (Primary) | ops5 (Secondary) |
|---|---|---|
| **Role** | Main ZFS backup target (backup.one) | Secondary backup target (backup.two) |
| **Drives** | 3× 4 TB (ST4000VN008) | 3× 6 TB (ST6000VN0033) |
| **Pool** | `tank` | `tank` |
| **RAID** | RAIDZ | RAIDZ |
| **ZFS Version** | Declarative (NixOS modules) | Declarative (NixOS modules) |
| **SSH Port** | `6623` | `6623` |

---

## 🏗️ Architecture

```
┌─────────────┐           ZFS Pool "tank"           ┌────────────┐
│   ops       │  ──rsync──►  ops4 (primary) 💾  ──  │ ops5 (sec) │
│   ops2      │           /mnt/tank/backup/         │ /mnt/tank/ │
│   ops3      │  ──rsync──►  ops5 (secondary) ──  ──► backup.one │
└─────────────┘                                     └────────────┘
                                                      backup.two
```

**Pool Layout:**

| Dataset | Mount | Permissions | Notes |
|---|---|---|---|
| `tank` | `/mnt/tank` | root | Root dataset, compress=zstd-4, recordsize=1M, atime=off |
| `tank/backup` | `/mnt/tank/backup` | `backup:backup` (0770) | rsync receive target, metadata-cache warmed hourly |
| `tank/samba` | `/mnt/tank/samba` | `samba:samba` (0770) | Case-insensitive (Windows clients), metadata-cache warmed via systemd |

### Key Systemd Services

| Service | Description | Schedule |
|---|---|---|
| `zfs-cache-meta-samba-timer` | Warms filesystem metadata cache on samba dataset | Hourly |
| `zfs-cache-meta-backup-timer` | Warms filesystem metadata cache on backup dataset | Daily at 22:55 |
| `zfs-auto-snapshot.timer` | Auto-snapshots (hourly/daily/weekly/monthly) | Per-retention policy |
| `zfs-auto-scrub.timer` | Pool scrub (check for silent corruption) | Weekly |
| `zfs-trim.timer` | Trim unused blocks on SSDs | Weekly |
| `fstrim.timer` | Filesystem trim via systemctl | Weekly |

### Snapshot Retention Policy

| Frequency | Keep |
|---|---|
| Frequent | 0 (disabled) |
| Hourly | 24 |
| Daily | 7 |
| Weekly | 4 |
| Monthly | 4 |

---

## ⚙️ Declarative Configuration

All ZFS settings on ops4/ops5 are defined in `storage/zfs.nix` — this is the **single source of truth**. Do not manually set pool/dataset properties outside of this file.

```nix
# storage/zfs.nix
{
  # Boot: kernel params for ZFS tuning
  boot.kernelParams = [
    "zfs.zfs_arc_max=0"                    # auto-arc (unlimited)
    "zfs.zfs_compressed_arc_enabled=1"     # compressed ARC
    "zfs.zfs_dirty_data_max__max_percent=50"
    "zfs.zfs_dirty_data_max_percent=45"
    "zfs.zfs_txg_timeout=600"              # TXG flush interval (10 min)
  ];

  # ZFS module
  boot.zfs = {
    devNodes = "/dev/disk/by-id";
    forceImportAll = false;
    forceImportRoot = false;
    extraPools = ["tank"];
  };

  # Auto-snapshot + scrub + trim
  services.zfs = {
    expandOnBoot = "all";
    autoSnapshot = {
      enable = true;
      frequent = 0; hourly = 24;
      daily = 7; weekly = 4; monthly = 4;
    };
    autoScrub = { enable = true; interval = "weekly"; };
    trim = { enable = true; interval = "weekly"; };
  };
}
```

### Key Dataset Properties

| Property | Value | Rationale |
|---|---|---|
| `compress` | `zstd-4` | Great balance of speed & ratio |
| `recordsize` | `1M` | Optimized for large backup files |
| `atime` | `off` | Reduces write amplification |
| `sync` | `disabled` | Best-effort I/O (acceptable for backups) |
| `acltype` | `posixacl` | Full POSIX ACL support |
| `aclinherit` | `passthrough` | Preserve ACLs during copy/clone |
| `xattr` | `sa` | Extended attrs stored in inode (faster) |
| `exec` | `off` | Prevent executable code on backup |
| `devices` | `off` | Block device nodes not stored |
| `snapdir` | `visible` | Snapshots visible in listings |

---

## 📊 Monitoring & Reporting

### Quick Overview

```bash
echo "########## OPS4 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops4 'zpool status -v && zfs list'
echo "########## OPS5 ZFS REPORT: press YubiKey ##########"
ssh -p 6623 me@ops5 'zpool status -v && zfs list'
```

### JSON Output (with jq)

```bash
# Pool status + dataset list
ssh -p 6623 me@ops4 'zpool status -v --json' | jq
ssh -p 6623 me@ops4 'zfs list --json' | jq

# Full property dump
ssh -p 6623 me@ops4 'zfs get all --json' | jq
```

### Snapshot Inventory

```bash
ssh -p 6623 me@ops4 'zfs list -t snapshot -o name,creation,used'
ssh -p 6623 me@ops5 'zfs list -t snapshot -o name,creation,used'
```

### Disk Health (SMART)

```bash
# ops4 (4 TB Seagate drives)
ssh -p 6623 me@ops4 'sudo smartctl --all /dev/sda'
ssh -p 6623 me@ops4 'sudo smartctl --all /dev/sdb'
ssh -p 6623 me@ops4 'sudo smartctl --all /dev/sdc'

# ops5 (6 TB Seagate drives)
ssh -p 6623 me@ops5 'sudo smartctl --all /dev/sda'
ssh -p 6623 me@ops5 'sudo smartctl --all /dev/sdb'
ssh -p 6623 me@ops5 'sudo smartctl --all /dev/sdc'
```

> 💡 **Tip**: SMART data is also exported via Prometheus (`node_exporter` + `smartctl` collector) on `/dev/nvme0` + all SATA disks.

---

## 🔨 Pool Operations

### Prerequisites

List available disks by ID:

```bash
ls -la /dev/disk/by-id
```

### Recreate the Pool (Destructive — Only for Fresh Setup)

⚠️ **WARNING**: This destroys all data on the target disks.

**ops4** (3× 4 TB):

```bash
sudo zpool destroy tank > /dev/null 2>&1
sudo zpool create -f -m /mnt/tank -o ashift=12 -o autotrim=on \
  tank raidz \
  ata-ST4000VN008-2DR166_ZM40X8TA \
  ata-ST4000VN008-2DR166_ZM40XDSE \
  ata-ST4000VN008-2DR166_ZM40XVH0
sudo zpool status -v
sudo zpool list -v
```

**ops5** (3× 6 TB):

```bash
sudo zpool destroy tank > /dev/null 2>&1
sudo zpool create -f -m /mnt/tank -o ashift=12 -o autotrim=on \
  tank raidz \
  ata-ST6000VN0033-2EE110_ZAD9WLLC \
  ata-ST6000VN0033-2EE110_ZAD9WLED \
  ata-ST6000VN0033-2EE110_ZAD9T708
sudo zpool status -v
sudo zpool list -v
```

### Create Datasets

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
sudo zfs list
```

---

## 🔍 Troubleshooting

| Problem | Check | Fix |
|---|---|---|
| Pool won't import | `zpool status` / `zpool import` | Check `/dev/disk/by-id` links exist after reboots |
| Scrub running too long | `zpool status` | Normal for large RAIDZ; scrub is weekly via systemd |
| High ARC memory pressure | `zpool list` (USED column) | Check `zfs.zfs_arc_max` kernel param; set to fixed size if needed |
| Pool degraded | `zpool status -v` | Replace failed disk: `zpool replace tank <old> <new>` then `zpool replace tank <degraded>` |
| Snapshots consuming space | `zfs list -t snapshot` | `zfs snapshot -r tank@dontneed` then `zfs destroy -r tank@dontneed` |
| `zfs-auto-snapshot` not running | `systemctl status zfs-auto-snapshot.timer` | Enable with `make switch` — timer is declared in `zfs.nix` |
| Auto-trim not working | `systemctl status zfs-trim.timer` | Ensure `autotrim=on` was set at pool creation time |

---

## 📁 Key Paths & Files

| Path | Purpose |
|---|---|
| `storage/zfs.nix` | Full declarative ZFS config — pool params, datasets, systemd timers |
| `storage/zdash.nix` | Imported sub-config (ZFS dash helpers) |
| `/etc/scripts/rsync-backup.sh` | rsync backup orchestration target |
| `/mnt/tank/backup` | rsync receive target — where backups land |
| `/mnt/tank/samba` | Windows-compatible share storage |
| `/dev/disk/by-id` | Persistent device symlinks used for pool creation |

---

> ⚡ *Two servers, three drives each, fully declarative. If a disk dies, replace it and run `make switch` to re-apply the config.*
