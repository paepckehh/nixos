# State Storage Infrastructure

> Declarative, stateless NixOS storage with ZFS-backed redundancy, automated backups, and impermanence-driven configurations — all managed through a single flake source of truth.

[![NixOS](https://img.shields.io/badge/NixOS-24.11-blue)](https://nixos.org)
[![ZFS](https://img.shields.io/badge/ZFS-RaidZ-green)](https://openzfs.org)
[![NixOS Containers](https://img.shields.io/badge/Containers-NixOS-orange)](https://nixos.org/manual/nixos/stable/#sec-nixos-containers)
[![rsync](https://img.shields.io/badge/Backup-rsync-blueviolet)](https://rsync.samba.org)

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Storage Nodes](#storage-nodes)
- [Stateless Client Configurations](#stateless-client-configurations)
- [Backup & Restore](#backup--restore)
- [Disko Disk Layouts](#disko-disk-layouts)
- [ISO / Auto-Installer](#iso--auto-installer)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Quick Links](#quick-links)

---

## Overview

This repository contains all NixOS storage infrastructure definitions for our server fleet and client machines. It covers:

- **ZFS storage pools** on dedicated backup servers (ops4, ops5) with RAIDZ protection
- **Stateless (impermanence) configurations** for NixOS clients — system state is ephemeral; only `/nix/persist` survives reboots
- **Automated rsync + ZFS snapshot backups** with daily scheduling and dual-target redundancy
- **Disko-driven disk layouts** for fresh provisioning, auto-installers, and USB boot media

Everything is declarative — no manual configuration drift.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     NixOS Client Fleet                          │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐                 │
│  │  ops   │  │ ops2   │  │ ops3   │  │ ops4/5 │                 │
│  │ [RO]   │  │ [RO]   │  │ [RO]   │  │ [RO]   │                 │
│  └───┬────┘  └───┬────┘  └───┬────┘  └───┬────┘                 │
│      │           │           │           │                      │
│      └───────────┴─────┬─────┘           │                      │
│                        │                 │                      │
│              rsync  ←──┘     nixos-   ←──┘                      │
│              (23:15 daily) container │                          │
└───────────────┬───────────────────┬──┴──┘───────────────────────┘
                │                   │
      ┌─────────▼────────┐  ┌──────▼──────┐
      │   ops4 (Primary) │  │  ops5 (Sec) │
      │   backup.one     │  │ backup.two  │
      │   3× 4 TB RAIDZ  │  │ 3× 6 TB R.  │
      │ /mnt/tank/backup │  │ /mnt/tank/  │
      └──────────────────┘  └─────────────┘
```

---

## Storage Nodes

Two dedicated ZFS storage servers (`ops4` and `ops5`) serve as the backup backend for the entire fleet.

| Feature | ops4 (Primary) | ops5 (Secondary) |
|---|---|---|
| Role | Main ZFS backup target | Redundant backup target |
| Pool | `tank` | `tank` |
| Disks | 3× 4 TB (ST4000VN008) | 3× 6 TB (ST6000VN0033) |
| RAID | RAIDZ | RAIDZ |
| SSH Port | `6623` | `6623` |
| Datasets | `tank/backup`, `tank/samba` | `tank/backup` |

### Dataset Properties

| Property | Value | Rationale |
|---|---|---|
| `compress` | `zstd-4` | Speed/ratio balance |
| `recordsize` | `1M` | Large backup files |
| `atime` | `off` | Reduce write amplification |
| `sync` | `disabled` | Best-effort I/O for backups |
| `exec` | `off` | Block code execution on storage |

> **Full ZFS documentation**: [ZFS.md](./ZFS.md) — pool layout, snapshot retention, monitoring, and pool operations.

---

## Stateless Root (!) Configurations

All client and server machines use **impermanence** — the root filesystem is read-only, and only selected paths survive across reboots in `/nix/persist`.

### Available Configurations

| Config | File | LUKS Encrypted | Description |
|---|---|---|---|
| Stateless (plain) | [disko/impermanence.nix](./disko/impermanence.nix) | No | Base stateless layout |
| Stateless (LUKS) | [disko/impermanence-luks.nix](./disko/impermanence-luks.nix) | Yes | Stateless with disk encryption |
| Basic | [basic.nix](./basic.nix) | No | Traditional stateful layout (reference) |
| Basic (LUKS) | [stateless-luks.nix](./stateless-luks.nix) | Yes | Stateful with disk encryption |

### Persisted Paths

```
/nix/persist/
├── home/       → bind-mounted to /home
├── var/lib/    → bind-mounted to /var/lib
├── etc/nixos/  → bind-mounted to /etc/nixos
└── etc/ssh/    → host keys
```

See also the legacy configurations in [`.attic/`](./.attic/) for historical reference.

---

## Backup & Restore

Automated daily backups via rsync to dual targets, with ZFS snapshot-based retention.

| Parameter | Value |
|---|---|
| Engine | rsync + rrsync (restricted chroot) |
| Schedule | Daily at 23:15 via systemd timer |
| Source | `/mnt/ro/var/lib` (read-only bind mount) |
| Targets | `backup@ops4` (mon/wed/fri), `backup@ops5` (tue/thu/sat/sun) |
| Container Backup | All `nixos-container` instances (stopped, backed up, restarted) |
| Database Backup | PostgreSQL, MySQL (stopped for consistency) |
| ACL Preservation | Full recursive ACLs via `getfacl` → `.acl-map` |

> **Full backup documentation**: [BACKUP.md](./BACKUP.md) — restore procedures, troubleshooting, key paths.

---

## Disko Disk Layouts

Disko definitions declaratively format and mount disks for new or rebuilt machines.

| Layout | Path | Description |
|---|---|---|
| Basic | [disko/basic.nix](./disko/basic.nix) | Standard disk layout (reference) |
| Stateless | [disko/impermanence.nix](./disko/impermanence.nix) | Stateless root + persist bind mounts |
| Stateless + LUKS | [disko/impermanence-luks.nix](./disko/impermanence-luks.nix) | Encrypted stateless layout |

### Provisioning (Makefile)

```bash
# Format and install a new machine (LUKS mode)
make TARGET=ops1 TARGETDRIVE=sda

# Wipe and re-provision
make TARGET=ops1 wipe

# USB boot media
make TARGET=ops1 usb
```

---

## ISO / Auto-Installer

Automated NixOS installer images for zero-touch provisioning.

| ISO | Path | Description |
|---|---|---|
| Auto-installer | [iso-autoinstaller.nix](./iso-autoinstaller.nix) | Automated fresh install with disko |
| Live USB | [iso-live.nix](./iso-live.nix) | Rescue/debug live environment |

---

## Monitoring & Maintenance

### Quick Status Check

```bash
# ZFS pool health
ssh -p 6623 me@ops4 'zpool status -v && zfs list'
ssh -p 6623 me@ops5 'zpool status -v && zfs list'

# Snapshot inventory
ssh -p 6623 me@ops4 'zfs list -t snapshot -o name,creation,used'

# Disk health (via Prometheus node_exporter + smartctl)
ssh -p 6623 me@ops4 'sudo smartctl --all /dev/sda'
```

### Automated Jobs

| Service | Schedule | Purpose |
|---|---|---|
| `zfs-auto-snapshot.timer` | Hourly/daily/weekly/monthly | Auto-snapshots (retention in ZFS.md) |
| `zfs-auto-scrub.timer` | Weekly | Pool scrub for silent corruption |
| `zfs-trim.timer` | Weekly | Trim unused SSD blocks |
| `zfs-cache-meta-backup-timer` | Daily 22:55 | Warm metadata cache on backup dataset |
| `zfs-cache-meta-samba-timer` | Hourly | Warm metadata cache on samba dataset |
| `rsync-backup.timer` | Daily 23:15 | Automated backup via rsync |

---

## Quick Links

| Document | Description |
|---|---|
| [**ZFS.md**](./ZFS.md) | ZFS pool architecture, config, monitoring, pool operations |
| [**BACKUP.md**](./BACKUP.md) | Backup engine, restore guides, schedule matrix, troubleshooting |
| [**Makefile**](./Makefile) | Provisioning commands for disk layouts and USB media |
| [**disko/basic.nix**](./disko/basic.nix) | Reference disk layout |
| [**disko/impermanence.nix**](./disko/impermanence.nix) | Stateless disk layout (no encryption) |
| [**disko/impermanence-luks.nix**](./disko/impermanence-luks.nix) | Stateless disk layout with LUKS encryption |
| [**zfs.nix**](./zfs.nix) | Declarative ZFS configuration (single source of truth) |
| [**backup.nix**](./backup.nix) | Declarative backup service & timer definitions |
| [**.attic/**](./.attic/) | Legacy/discontinued configurations for reference |
