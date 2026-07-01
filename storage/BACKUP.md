# 💾 Backup & Restore

> Your data's safety net — auto-powered by rsync, ZFS snapshots, and two redundant backup servers (ops4 + ops5).

---

## 🚀 Quick Overview

| Feature | Details |
|---|---|
| **Backup Engine** | `rsync` + `rrsync` (restricted, chroot-style) |
| **Schedule** | Daily at **23:15** via systemd timer |
| **Source** | `/mnt/ro/var/lib` (read-only bind mount of `/nix/persist/var`) |
| **Targets** | `backup@ops4` (backup.one) and `backup@ops5` (backup.two) |
| **SSH Port** | `6623` |
| **ZFS Snapshots** | Daily 22:15 on backup hosts — 7 days / 4 weeks / 4 months retention |
| **Containers Backed Up** | All `nixos-container` instances (e.g., nextcloud, paperless, …) |
| **Databases Backed Up** | `postgresql`, `mysql` (stopped during backup for consistency) |
| **ACL Preservation** | Full recursive ACLs backed up via `getfacl` → `/var/lib/.acl-map` |

---

## ⚙️ How It Works (Under the Hood)

### Architecture

```
┌──────────────┐    rsync + SSH (6623)     ┌──────────────┐
│   ops / ops2 │ ──────────────────────►   │  ops4 ─┐     │
│   ops3/4/5   │  (backup@ ops4 or ops5)   │              │
└──────────────┘                           │ ZFS snaps    │
                                           │ 7d/4w/4m     │
                                     ┌─────┘          ◄───┘
                                     │
                                     │
                                ┌──────────┐
                                │  Backup   │
                                │  Hosts    │
                                └──────────┘
```

### The Backup Script (`rsync-backup.sh`)

1. 🚫 **Root check** — exits immediately if not run as root
2. 🔒 **Locking** — creates `/var/run/backup/global.lock` (exits if lock exists; no concurrent overlap)
3. 🧹 **Cleanup** — removes any leftover temp files from previous runs
4. 📅 **Day-based routing** — determines which backup host to send data to based on hostname + weekday:

| Host | Mon / Wed / Fri | Tue / Thu / Sat / Sun |
|---|---|---|
| `ops*` | `backup@ops4` | `backup@ops5` |
| `ops2*` | `backup@ops4` | `backup@ops5` |
| `*` (any other, `S` day) | ❌ no backup | ❌ no backup |

5. 📋 **ACL snapshot** — runs `getfacl --recursive` on `/var/lib` and saves to `.acl-map`
6. 💾 **Main backup** — rsyncs `/mnt/ro/var/lib` to target with `--checksum --delete --numeric-ids`
7. 🐳 **Container backup** — iterates all running `nixos-container` instances, stops each, backs up, then restarts
8. 🗄️ **Database backup** — stops `postgresql` / `mysql` (if present), backs up, starts back up
9. 🔄 **Three `sync` calls** — flush all write caches to disk before exit

### Systemd Timer

```nix
timerConfig = {
  OnCalendar = "*-*-* 23:15:00";
  Persistent = false;       # won't catch up missed runs
  Unit = "rsync-backup.service";
};
```

---

## 👤 Users & Access

### `backup` user
- **UID**: from `infra.backup.uid`
- **Password**: disabled (`hashedPassword = "$y$j9T$--fail--"`)
- **SSH**: restricted to `rrsync /mnt/tank/backup/` — can **only push** backups there, no reads
- **Key**: loaded from `/nix/persist/home/backup/.ssh/id_ed25519`

### `samba` user
- **UID**: from `infra.samba.uid`
- **SSH key**: locked (`***locked**`) — placeholder for future use

### Filesystem
- `/mnt/ro/var` → read-only bind mount of `/nix/persist/var` (with `noexec`, `nosuid`, `nodev`)
- Ensures backups are taken from a **consistent, unmodified** view of `/var/lib`

---

## 🔄 Restore Guide

### Restore a Full Server (ops1 / ops2)

```bash
# 1. Connect new NVME via USB as /dev/sda on your admin PC → move to server → boot
cd /etc/nixos && TARGET=ops[1|2] make sda   # assemble & restart

# 2. Restore lib from backup (ops4/ops5)
cd && make ssh.ops[1|2]
sudo ssh -p 6623 me@ops[4|5] 'tar -C /mnt/tank/backup/[optional:.zfs/@snapshot]/ops[1|2] -cf - lib' | tar -C /var/lib -xvf -

# 3. Restore ACLs & reboot
sudo setfacl --restore=/var/lib/.acl-map
sudo reboot
```

### Restore ops3 / ops4 / ops5

```bash
cd /etc/nixos && TARGET=ops[3|4|5] make sda   # assemble & restart
# (data lives on ZFS storage — see [ZFS.md](./ZFS.md))
```

### Restore a Single Container (e.g., nextcloud)

```bash
make ssh.ops2
sudo nixos-container stop nextcloud
sudo mv -f /var/lib/container/nextcloud /var/lib/container/nextcloud.$(date '+%Y-%m-%dT%H:%M:%S')

sudo ssh -p 6623 me@ops[4|5] \
  'tar -C /mnt/tank/backup/ops2/lib/nixos-container/.zfs/@<snapshot> -cf - nextcloud' \
  | tar -C /var/lib/nixos-container -xvf -

sudo nixos-container start nextcloud
```

> 🔍 Always verify file ownership against `/var/lib/.acl-map` before rebooting!

---

## 📊 Backup Schedule Matrix

| Machine | Monday | Wednesday | Friday | Tuesday | Thursday | Weekend |
|---|---|---|---|---|---|---|
| **ops** (ops4 route) | ✅ ops4 | ✅ ops4 | ✅ ops4 | ❌ | ❌ | ❌ |
| **ops2** (ops4 route) | ✅ ops4 | ✅ ops4 | ✅ ops4 | ❌ | ❌ | ❌ |
| **ops** (ops5 route) | ❌ | ❌ | ❌ | ✅ ops5 | ✅ ops5 | ❌ |
| **ops2** (ops5 route) | ❌ | ❌ | ❌ | ✅ ops5 | ✅ ops5 | ❌ |

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| Lockfile prevents backup | `rm -f /var/run/backup/global.lock` |
| SSH key missing | Check `/nix/persist/home/backup/.ssh/id_ed25519` exists |
| Backup runs but nothing transferred | See `.last-backup.run-without-action.*` log files |
| Permission errors on restored files | `sudo setfacl --restore=/var/lib/.acl-map` |
| Container won't start after restore | Check containers with `sudo nixos-container list` and verify ACLs |

---

## 📁 Key Files & Paths

| Path | Purpose |
|---|---|
| `/etc/scripts/rsync-backup.sh` | Main backup orchestration script |
| `/var/run/backup/` | Runtime lock & temp files |
| `/var/lib/.acl-map` | Saved ACL map for restore |
| `/var/lib/.last-backup.*` | Timestamped logs (start / finish / noop) |
| `/mnt/ro/var/lib` | Read-only view of backing-store for consistent backups |
| `/nix/persist/home/backup/.ssh/` | SSH key for backup destination auth |

---

> ⚡ *Powered by rsync + ZFS + systemd — all fully automatic. Just monitor and restore when needed.*
