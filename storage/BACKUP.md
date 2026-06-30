# 🗄️ Backup & Restore

> Automated, declarative backups for NixOS containers and host state — ZFS-native snapshots + rsync offsite.

## Quick Reference

| Action | Command |
|---|---|
| Restore ops / ops2 from snapshot | See [Restore ops, ops2](#restore-ops--ops2) |
| Restore ops3/4/5 (with ZFS) | See [Restore ops3/4/5](#restore-ops345) |
| Restore a container (e.g. nextcloud) | See [Restore Containers](#restore-containers) |
| View backup schedule | See [Automatic Schedule](#automatic-backup-schedule) |

---

## Restore Ops / ops2

These hosts back up their `/var/lib` and container state to the backup targets over SSH on port `6623`.

### Steps

1. Connect the new NVMe via USB to your admin PC, then move it to the server and boot.
2. Assemble the disk and reboot:

    ```bash
    cd /etc/nixos && TARGET=ops[1|2] make sda
    ```

3. Pull the backup from the backup host (replace snapshot path as needed):

    ```bash
    make ssh.ops[1|2]
    sudo ssh -p 6623 me@ops[4|5] 'tar -C /mnt/tank/backup/ops[1|2] -cf - lib' \
      | tar -C /var/lib -xvf -
    sudo reboot
    ```

---

## Restore ops3 / ops4 / ops5

For hosts with ZFS-backed storage, see [ZFS.md](./ZFS.md) for pool-level operations.

### Steps

1. Connect the new NVMe via USB to your admin PC, then move it to the server and boot.
2. Assemble and restart:

    ```bash
    cd /etc/nixos && TARGET=ops[3|4|5] make sda
    ```

That's it — the host pulls its state from the ZFS backup on `ops4`/`ops5`.

---

## Restore Containers

Restoring a container (e.g. `nextcloud`, `paperless`) from a snapshot:

```bash
make ssh.ops2
sudo nixos-container stop nextcloud
sudo mv -f /var/lib/nixos-container/nextcloud /var/lib/nixos-container/nextcloud.$(date '+%Y-%m-%dT%H:%M:%S')
sudo ssh -p 6623 me@ops[4|5] \
  'tar -C /mnt/tank/backup/ops2/lib/nixos-container/.zfs/@<snapshot> -cf - nextcloud' \
  | tar -C /var/lib/nixos-container -xvf -
sudo nixos-container start nextcloud
```

> **Note:** Replace `<snapshot>` with the actual snapshot name, e.g. `@daily-2026-06-28`.

---

## Automatic Backup Schedule

Backups run fully automatic — no manual intervention needed.

| Target | Hosts |
|---|---|
| `backup.one` (= ops4) | ops (Mon/Wed/Fri), ops2 (Tue/Thu) |
| `backup.two` (= ops5) | ops (Tue/Thu), ops2 (Mon/Wed/Fri) |

### Schedule Logic

```bash
case $HOST:$WEEKDAY in
  ops:Monday|ops:Wednesday|ops:Friday)   TARGET=${infra.backup.one} ;;
  ops:Tuesday|ops:Thursday)             TARGET=${infra.backup.two} ;;
  ops2:Monday|ops2:Wednesday|ops2:Thursday) TARGET=${infra.backup.two} ;;
  ops2:Tuesday|ops2:Friday)             TARGET=${infra.backup.one} ;;
esac
```

### What Gets Backed Up

| Source | Destination | Method |
|---|---|---|
| `/var/lib` (host state) | `tank/backup/<hostname>` | rsync over SSH (port 6623) |
| NixOS containers | `tank/backup/<hostname>/lib/nixos-containers/<container>` | rsync per container (stop → sync → start) |
| ZFS snapshots | Retained on `tank` pool | autoSnapshot (hourly, daily, weekly, monthly) |

### Schedule Details

| Type | Frequency | Retention |
|---|---|---|
| Full snapshots | Daily at 22:15 (concurrent, cross-host) | 7 days |
| Weekly snapshots | 4 retained | 4 weeks |
| Monthly snapshots | 4 retained | 4 months |

---

## 🔧 How It Works

The backup process is orchestrated via a NixOS systemd timer + shell script (`/etc/scripts/rsync-backup.sh`):

1. **Lock acquisition** — a global lock file prevents concurrent runs.
2. **Host routing** — hostname + weekday determine the backup target (`ops4` or `ops5`).
3. **Container backup** — each nixos-container is stopped, rsync'd, then restarted.
4. **Filesystem sync** — triple `sync` ensures data hits disk before the timer fires again.

The `backup` user on backup hosts is restricted via `rrsync` to `/mnt/tank/backup/` only.

---

## 📊 Monitoring Last Backup

Touch files are created to track backup timing:

| File | Meaning |
|---|---|
| `.last-backup.startup.<host>.<target>.<weekday>.<timestamp>` | Backup started |
| `.last-backup.finish.<host>.<target>.<weekday>.<timestamp>` | Backup completed |
| `.last-backup.finish-without-action.<host>.<target>.<weekday>.<timestamp>` | Skipped (no action needed — host is a backup target) |

---

## 🔐 SSH Configuration

Backups authenticate via Ed25519 key stored at `/nix/persist/home/backup/.ssh/id_ed25519`. The key is injected into the rsync SSH command with the following options:

| Option | Purpose |
|---|---|
| `-p 6623` | Non-standard SSH port |
| `-i $KEY` | Key file path |
| `rrsync` | Restricted rsync — backup user can only read from `/mnt/tank/backup/` |
