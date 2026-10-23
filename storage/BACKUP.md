<div align="center">

# 💾 Backup & Restore

**rsync from a read-only view of `/var/lib`, routed daily to one of two ZFS backup servers.**

[![Engine](https://img.shields.io/badge/engine-rsync%20%2B%20rrsync-5277C3)](../storage/backup.nix)
[![Schedule](https://img.shields.io/badge/schedule-daily%2023%3A15-0891b2)](../storage/backup.nix)
[![Targets](https://img.shields.io/badge/targets-ops4%20%2B%20ops5-0d9488)](./ZFS.md)

`systemctl start rsync-backup.service`

</div>

---

## 🚀 What the service does

`storage/backup.nix` defines `rsync-backup.service` and `rsync-backup-timer`.
The script lives inline as `/etc/scripts/rsync-backup.sh`.

| Property | Value |
|---|---|
| Engine | `rsync -a --checksum --delete --stats` over SSH |
| Schedule | Daily at `23:15` (`Persistent = false`) |
| Source | `/mnt/ro/var/lib`, a read-only bind mount of `/nix/persist/var` |
| Targets | `backup@ops4` or `backup@ops5`, port `6623` |
| Containers | Every `nixos-container` listed, stopped, copied, restarted |
| SSH key | `/nix/persist/home/backup/.ssh/id_ed25519` |
| Lock | `/var/run/backup/global.up` |
| Logs | `/var/lib/.last-backup.{startup,finish,finish-without-action}.*` |

## ⚙️ Routing

The script derives a key from the first letter of the weekday and routes by
host name:

| Host | Key | Target |
|---|---|---|
| `ops` | `S` (Sunday) | no backup |
| `ops` | `T` (Tuesday) | `backup@ops5` |
| `ops` | any other | `backup@ops4` |
| `ops2` | `T` (Tuesday) | `backup@ops4` |
| `ops2` | any other | `backup@ops5` |
| anything else | any | no backup |

So `ops` alternates between the two targets across the week, and `ops2` uses
the opposite target on the same day. Other host names are skipped explicitly.

## 🚀 Run it now

```bash
sudo systemctl start rsync-backup.service
systemctl status rsync-backup.service
journalctl -u rsync-backup.service --since today
ls -l /var/lib/.last-backup.*
```

The service is `oneshot`; it returns when the rsync run finishes.

## 🔄 Restore

### Full server

```bash
# 1. Provision the machine from the storage Makefile
cd /etc/nixos
TARGET=ops1 make sda

# 2. Pull lib back from a backup host
sudo ssh -p 6623 me@ops4 \
  'tar -C /mnt/tank/backup/ops1 -cf - lib' \
  | sudo tar -C /var/lib -xvf -

# 3. Reboot
sudo reboot
```

Add a snapshot path (for example `.../ops1/.zfs/snapshot/<name>`) to restore an
older point in time.

### Single container

```bash
sudo nixos-container stop nextcloud
sudo mv -f /var/lib/nixos-containers/nextcloud \
  /var/lib/nixos-containers/nextcloud.$(date '+%Y-%m-%dT%H:%M:%S')

sudo ssh -p 6623 me@ops4 \
  'tar -C /mnt/tank/backup/ops1/lib/nixos-containers -cf - nextcloud' \
  | sudo tar -C /var/lib/nixos-containers -xvf -

sudo nixos-container start nextcloud
```

## 👤 Access model

| User | Purpose |
|---|---|
| `backup` | rsync receiver. SSH key is restricted with `rrsync /mnt/tank/backup/`; it can write there and cannot read elsewhere. |
| `samba` | SMB share owner. SSH key is a locked placeholder. |

The backup source is mounted read-only (`ro`, `noexec`, `nosuid`, `nodev`) so a
compromised backup job cannot modify live state.

## 🛠️ Troubleshooting

| Problem | Check | Fix |
|---|---|---|
| Script exits immediately | `EUID` | Run through the systemd service or as root |
| `global lock, exit` | `/var/run/backup/global.up` | Wait for the running job or remove a stale lock |
| SSH key missing | `/nix/persist/home/backup/.ssh/id_ed25519` | Restore the key from persist |
| Nothing transferred | `/var/lib/.last-backup.finish-without-action.*` | The host or weekday is not routed |
| Container copy fails | `nixos-container list` | Check the container name and that it stops cleanly |

## 📁 Key paths

| Path | Purpose |
|---|---|
| `/etc/scripts/rsync-backup.sh` | Generated script from `backup.nix` |
| `/mnt/ro/var/lib` | Read-only backed-up view |
| `/var/run/backup/` | Lock directory |
| `/var/lib/.last-backup.*` | Run markers |
| `/mnt/tank/backup/<host>` | Receive target on ops4/ops5 |

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="./ZFS.md">ZFS</a> · <a href="./README.md">storage</a></sub></p>
