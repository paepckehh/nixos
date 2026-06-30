# 💾 Storage — ZFS Backups & NixOS Storage Layouts

> Declarative storage configs for NixOS: disk layouts via [disko](https://github.com/nix-community/disko), ZFS pool management, and automated rsync backup orchestration.

---

## ✨ What's Here

This directory contains two categories of storage configuration:

- **Storage Layouts** (`*.nix`) — declarative disk/partition/pool definitions for NixOS via disko, covering stateless, stateless-LUKS, and ZFS profiles.
- **Operations Docs** (`BACKUP.md`, `ZFS.md`) — runbooks for backup/restore workflows and ZFS pool creation, properties, and troubleshooting.

## 📁 Directory Structure

| Path | Purpose |
|---|---|
| `flake.nix` | *(deprecated, moved to root)* |
| `basic.nix` | Minimal disk layout — no encryption, no ZFS |
| `stateless.nix` | Stateless root (`/` on tmpfs), persistent data under `/nix/persist` |
| `stateless-luks.nix` | Stateless root + LUKS encryption |
| `stateless-autoinstaller.nix` | Stateless layout for the NixOS auto-installer |
| `stateless-luks-autoinstaller.nix` | Encrypted stateless layout for auto-installer |
| `stateless-luks-sequence.nix` | Sequential LUKS + stateless layout (ops2) |
| `zfs.nix` | Full ZFS pool config — auto-snapshot, auto-scrub, trim, metadata cache |
| `backup.nix` | Rsync backup service, users, systemd timer, container snapshot logic |
| `iso.nix` | NixOS ISO installer disk layout |
| `iso-live.nix` | Live USB layout |
| `iso-autoinstaller.nix` | Auto-installer ISO layout |
| `disko/` | Legacy disko configurations (stateless, stateless-luks, autoinstallers) |
| `.attic/` | Archived/discontinued layouts for reference |
| `BACKUP.md` | Runbook: restore ops, containers, backup schedule |
| `ZFS.md` | Runbook: pool creation, properties, monitoring, troubleshooting |
| `Makefile` | Make targets for building/installing disk layouts |

## 🚀 Quick Start

### View a Disk Layout

```bash
cat disko/stateless.nix
```

### Build & Deploy a Profile

```bash
make build   # build from /etc/nixos
make boot    # build + reboot
```

### Import a Storage Profile

```nix
# In your NixOS configuration
{
  imports = [
    ./storage/stateless.nix
    # or
    ./storage/zfs.nix
  ];
}
```

## 📖 Runbooks

| Topic | Doc |
|---|---|
| Backup & restore workflows | [BACKUP.md](./BACKUP.md) |
| ZFS pool creation & properties | [ZFS.md](./ZFS.md) |

## 🔐 Key Security Notes

- Backup SSH connections use port `6623` with Ed25519 keys, restricted via `rrsync`.
- Stateless profiles wipe `/` on reboot; persistent data lives under `/nix/persist`.
- LUKS profiles encrypt the root partition; ZFS profiles rely on pool-level encryption options if enabled.

## 📊 Backup Overview

| Type | Source | Destination | Frequency |
|---|---|---|---|
| rsync | `/var/lib` + NixOS containers | `tank/backup/<host>` daily | 22:15 |
| ZFS snapshots | `tank` pool | local snapshots | Daily + weekly + monthly |

## ⚠️ Warning

> This repo is for rapid prototyping and wild tests. **Do not use anything in production without review!**

---

*For full infrastructure context, see the [main README](../README.md).*
