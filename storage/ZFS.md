# 📦 ZFS Storage Pool

> ZFS (`tank`) — RAID-Z pools on ops4 (3× 4TB) and ops5 (3× 6TB) with automated snapshots and TRIM.

## Quick Reference

| Action | Command |
|---|---|
| Pool overview | [Status & List](#status--list) |
| JSON output | [JSON Reports](#json-reports) |
| Snapshot overview | [Snapshots](#snapshots) |
| Create pool | [Create Tank](#create-tank) |
| Configure pool | [Mountpoints & Properties](#mountpoints--properties) |

---

## Status & List

### Quick overview (YubiKey required)

```bash
echo "########## OPS4 ZFS REPORT ##########"
ssh -p 6623 me@ops4 'zpool status -v && zfs list'
echo "########## OPS5 ZFS REPORT ##########"
ssh -p 6623 me@ops5 'zpool status -v && zfs list'
```

### JSON Reports (requires `jq`)

**Basic JSON:**
```bash
ssh -p 6623 me@ops4 'zpool status -v --json' | jq
ssh -p 6623 me@ops4 'zfs list --json' | jq
ssh -p 6623 me@ops5 'zpool status -v --json' | jq
ssh -p 6623 me@ops5 'zfs list --json' | jq
```

**Full details (includes all properties):**
```bash
ssh -p 6623 me@ops4 'zfs get all --json' | jq
ssh -p 6623 me@ops5 'zfs get all --json' | jq
```

### Snapshot Overview

```bash
ssh -p 6623 me@ops4 'zfs list -t snapshot -o name,creation,used'
ssh -p 6623 me@ops5 'zfs list -t snapshot -o name,creation,used'
```

---

## Create Tank

### 1. List Available Disks

```bash
ls -la /dev/disk/by-id
```

### 2. Create the Pool

**ops4** (3× 4TB WD Red):
```bash
sudo zpool destroy tank > /dev/null 2>&1  # cleanup if needed
sudo zpool create -f -m /mnt/tank \
  -o ashift=12 -o autotrim=on \
  tank raidz \
  ata-ST4000VN008-XXX ata-ST4000VN008-XXX ata-ST4000VN008-XXX
sudo zpool status -v
sudo zpool list -v
```

**ops5** (3× 6TB WD Red):
```bash
sudo zpool destroy tank > /dev/null 2>&1  # cleanup if needed
sudo zpool create -f -m /mnt/tank \
  -o ashift=12 -o autotrim=on \
  tank raidz \
  ata-ST6000VN0033-XXX ata-ST6000VN0033-XXX ata-ST6000VN0033-XXX
sudo zpool status -v
sudo zpool list -v
```

---

## Mountpoints & Properties

### Dataset Layout

| Dataset | Purpose | ACL Type |
|---|---|---|
| `tank` | Root of storage pool | posixacl |
| `tank/backup` | Backup storage | posixacl |
| `tank/samba` | SMB file shares | case-insensitive |

### Set Properties

```bash
# Enable ZFS auto-snapshot
sudo zfs set com.sun:auto-snapshot=true tank
sudo zfs set com.sun:auto-snapshot:frequent=false tank  # disabled
sudo zfs set com.sun:auto-snapshot:hourly=true tank
sudo zfs set com.sun:auto-snapshot:daily=true tank
sudo zfs set com.sun:auto-snapshot:weekly=true tank
sudo zfs set com.sun:auto-snapshot:monthly=true tank

# ACL & filesystem tuning
sudo zfs set aclinherit=passthrough tank
sudo zfs set acltype=posixacl tank
sudo zfs set xattr=sa tank
sudo zfs set atime=off tank
sudo zfs set recordsize=1M tank
sudo zfs set compress=zstd-4 tank
sudo zfs set sync=disabled tank          # perf-first — data loss acceptable for backup/samba
sudo zfs set exec=off tank
sudo zfs set devices=off tank
sudo zfs set snapdir=visible tank

# Create datasets
sudo zfs create tank/backup
sudo zfs create -o casesensitivity=insensitive tank/samba

sudo zfs list
```

---

## NixOS Integration

The ZFS pool is managed declaratively via NixOS modules:

| Module | Purpose |
|---|---|
| `zfs.nix` | Pool, auto-snapshot, auto-scrub, TRIM, metadata cache |
| `backup.nix` | rsync backup user, systemd timer, container snapshots |
| `zdash.nix` | ZFS dashboard via Prometheus exporter |

### NixOS Service Configuration

| Service | Setting | Value |
|---|---|---|
| `zfs.autoScrub` | `enable` | `true` (weekly) |
| `zfs.autoSnapshot.hourly` | retained snapshots | 24 |
| `zfs.autoSnapshot.daily` | retained snapshots | 7 |
| `zfs.autoSnapshot.weekly` | retained snapshots | 4 |
| `zfs.autoSnapshot.monthly` | retained snapshots | 4 |
| `zfs.trim` | `enable` | `true` (weekly) |
| `fstrim` | `interval` | weekly |
| `prometheus.exporters.node` | `enabledCollectors` | `["zfs"]` |

### Systemd Timers

| Timer | Schedule | Purpose |
|---|---|---|
| `zfs-cache-meta-samba` | :12, :32, :52 every hour | Hot-loads samba metadata into RAM |
| `zfs-cache-meta-backup` | Daily at 22:55 | Hot-loads backup metadata into RAM |

### Filesystem Layout

| Path | Mode | Owner |
|---|---|---|
| `/mnt/tank/backup` | `0775` | `root:wheel` |
| `/mnt/tank/samba` | `0775` | `root:wheel` |

---

## 🔍 Troubleshooting

| Symptom | Check |
|---|---|
| Pool not importing | `zpool status` — check disk identifiers in `/dev/disk/by-id` |
| Slow reads / writes | `zpool iostat -v` — verify no disk in `DEGRADED` state |
| Full pool | `zfs list -t snapshot` — prune old snapshots |
| Snapshots not appearing | Verify `zfs autoSnapshot` enabled and `cron` is running |
| TRIM not running | `service zfs-trim status` — check systemd timer |
