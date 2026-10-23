<div align="center">

# 💾 Storage

**Stateless root, LUKS, disko and ZFS. Reboot is a factory reset; `/nix/persist` is the only memory.**

[![Stateless](https://img.shields.io/badge/root-tmpfs-0d9488)](../storage/stateless.nix)
[![Disko](https://img.shields.io/badge/disko-declarative-5277C3)](https://github.com/nix-community/disko)
[![ZFS](https://img.shields.io/badge/ZFS-RAIDZ-0891b2)](./ZFS.md)
[![Backup](https://img.shields.io/badge/backup-rsync%20%2B%20snapshots-7c3aed)](./BACKUP.md)

`./storage/stateless-luks.nix`

</div>

---

## 🗂️ What's in here

| File | Purpose |
|---|---|
| `stateless.nix` | Stateless root on tmpfs with `/nix/persist` bind mounts |
| `stateless-luks.nix` | Stateless root plus LUKS encryption |
| `stateless-luks-fixed-6F6B-6565.nix` | Stateless + LUKS with fixed LUKS UUIDs (used by `srv`) |
| `stateless-luks-sequence.nix` | Stateless + LUKS sequence variant (used by `srv2`) |
| `stateless-autoinstaller.nix` | Stateless layout for automated installs |
| `stateless-luks-autoinstaller.nix` | Encrypted stateless layout for automated installs |
| `basic.nix` | Conventional stateful disk layout (reference / installer) |
| `zfs.nix` | ZFS pool, datasets, scrub, trim and snapshot policy for the backup fleet |
| `backup.nix` | rsync backup service and timer |
| `iso-live.nix` / `iso-autoinstaller.nix` / `iso.nix` | Live and installer ISO definitions |
| `disko/` | Reusable disko layouts (`basic`, `stateless`, `stateless-luks`, autoinstaller variants) |
| `disko-legacy.nix` / `disko-luks-legacy.nix` | Retained legacy layouts |
| `Makefile` | Destructive provisioning pipeline (`usb`, `wipe`, `format`, `migrate-persist`, …) |
| `.attic/` | Old layouts and working copies, never imported |

> The flake references `storage/base.nix` (for `client`) and
> `storage/stateless-luks-partlabel.nix` (for `internet` and `srv-full`). Neither
> file exists today; those targets fail evaluation until it is added.

## 🧊 Impermanence

Root is a tmpfs. Only the persisted paths survive a reboot:

```text
/nix/persist/
├── home/       → /home
├── var/lib/    → /var/lib
├── etc/nixos/  → /etc/nixos
└── etc/ssh/    → host keys, agenix identity
```

The persisted host key at
`/nix/persist/etc/ssh/ssh_host_ed25519_key` is also the agenix decryption
identity for servers.

## 💿 Disk layouts

Disko turns a Nix expression into partitions, filesystems and mounts. The
boot-critical layouts live under `storage/disko/`.

| Layout | File | Encryption |
|---|---|---|
| Basic | [`disko/basic.nix`](./disko/basic.nix) | No |
| Stateless | [`disko/stateless.nix`](./disko/stateless.nix) | No |
| Stateless + LUKS | [`disko/stateless-luks.nix`](./disko/stateless-luks.nix) | Yes |
| Stateless autoinstaller | [`disko/stateless-autoinstaller.nix`](./disko/stateless-autoinstaller.nix) | No |
| Stateless + LUKS autoinstaller | [`disko/stateless-luks-autoinstaller.nix`](./disko/stateless-luks-autoinstaller.nix) | Yes |

## 🚀 Provisioning

The `storage/Makefile` is destructive. Read it before running anything.

```bash
make -C storage info          # show assumptions and variables
make -C storage usb           # full pipeline: wipe → format → mount → install
make -C storage wipe          # wipe the target device
make -C storage migrate-persist
```

| Variable | Default | Meaning |
|---|---|---|
| `REPO` | `/etc/nixos` | Flake location |
| `TARGET` | hostname | `nixosConfigurations.<TARGET>` |
| `TARGETDRIVE` | — | Block device to provision (e.g. `sda`) |
| `USELUKS` | `YES` | Use the LUKS layout |
| `DISKOFLAKE` | `disko/stateless-luks.nix` | disko file to apply |

## 🛡️ Backups and ZFS

Two dedicated ZFS backup servers (`ops4`, `ops5`) receive daily rsync backups
and keep snapshots. See:

- [`BACKUP.md`](./BACKUP.md) — schedule, restore procedures, ACL handling.
- [`ZFS.md`](./ZFS.md) — pool layout, datasets, retention, monitoring.

```bash
ssh -p 6623 me@ops4 'zpool status -v && zfs list'
systemctl status rsync-backup.timer
```

## ⚠️ Safety

- `make sda`, `make sdb`, `make sdc`, `make usb`, `make wipe-home`, `make zero`
  erase data. Never run them unattended.
- Never edit a `.age` secret or replace it with plaintext.
- Verify the target device twice before formatting.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="./ZFS.md">ZFS</a> · <a href="./BACKUP.md">backup</a></sub></p>
