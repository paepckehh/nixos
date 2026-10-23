<div align="center">

# 🛠️ Admin

**YubiKey-backed WireGuard key vault and VPN operator shortcuts.**

[![YubiKey](https://img.shields.io/badge/keys-YubiKey%20PIV-7c3aed)](https://www.yubico.com)
[![WireGuard](https://img.shields.io/badge/VPN-WireGuard-0d9488)](https://wireguard.com)
[![Shell](https://img.shields.io/badge/make-one%20target%20per%20task-0891b2)](./Makefile.Generic)

`make wg-start-admin`

</div>

---

## 🗂️ What's in here

| File | Purpose |
|---|---|
| `Makefile.Generic` | Core logic: rekey, import to YubiKey, tunnel start/stop, tunnels, logs |
| `Makefile.Site.Home` | Site values: routes, endpoints, PIV slots, host IDs |
| `Makefile.Example` | Template for a new site |
| `keygen.sh` | Standalone WireGuard key-triple generator |
| `.attic/` | Retired site files |

### Sites

| Site | Route | WireGuard endpoint | WireGuard net | PIV slots |
|---|---|---|---|---|
| `ADMIN` | `10.20.0.0/23` | `178.13.0.208:51821` | `10.20.60` | PK `0x5fc110`, PSK `0x5fc111` |
| `OFFICE` | `10.20.6.0/23` | `178.13.0.208:51820` | `10.20.66` | PK `0x5fc112`, PSK `0x5fc113` |
| `LEGACY` | `192.168.22.0/24` | `178.13.0.208:51822` | `10.20.62` | PK `0x5fc114`, PSK `0x5fc115` |

## 🚀 Key lifecycle

```bash
# Generate a new triple, encrypt it, and import it into the YubiKey
make -f Makefile.Generic -f Makefile.Site.Home yubikey.rekey.admin
make -f Makefile.Generic -f Makefile.Site.Home yubikey.rekey.office
make -f Makefile.Generic -f Makefile.Site.Home yubikey.rekey.legacy
```

Flow:

1. `keygen.sh` writes plaintext `.pk`, `.psk`, `.pub` to `KEYGENDIR`.
2. The import step encrypts `.pk` and `.psk` with ChaCha20 using the site key and
   a per-rekey IV, then writes them into the YubiKey PIV objects.
3. The clear `.psk` and `.pub` are printed for the WireGuard server config.

## 🚀 Connect

```bash
make -f Makefile.Generic -f Makefile.Site.Home wg-start-admin
make -f Makefile.Generic -f Makefile.Site.Home wg-start-office
make -f Makefile.Generic -f Makefile.Site.Home wg-start-legacy

make -f Makefile.Generic -f Makefile.Site.Home wg-stop-admin
make -f Makefile.Generic -f Makefile.Site.Home wg-status
```

What happens:

1. Check the SSH agent has the smartcard key.
2. Check the route does not already exist.
3. Create a config under `~/.keyguard-<SITE>/`.
4. Mount a `tmpfs` (mode `0700`) for plaintext keys.
5. Decrypt keys from the YubiKey into memory and feed them to `wg set`.
6. Bring the interface up with `wg-quick`.
7. Stopping unmounts the tmpfs and destroys the plaintext keys.

## 🚀 Service access

| Target | Result |
|---|---|
| `ssh.ops` … `ssh.ops8` | SSH tunnel to an ops machine on port 6623 |
| `ssh.borg01` … `ssh.borg15` | SSH tunnel to a borg machine on port 6622 |
| `adguard`, `unifi`, `forgejo`, `opnborg`, `prometheus` | Port forward plus browser |
| `borg01` … `borg15` | Borg web interface on port 80 |
| `log.console`, `log.hostwatch`, `log.newstation`, `log.keycard` | Tail syslog-ng output through bat |
| `crush`, `skynet`, `boje01` … `boje03` | SSH tunnels to operator boxes |

`make kill.routes` removes all admin, office and legacy routes.

## 🔐 Security model

- **YubiKey PIV** — only encrypted blobs are stored on the key.
- **ChaCha20** — keys are encrypted with the site key and a per-rekey IV.
- **tmpfs** — plaintext keys exist only in RAM and die on disconnect.
- **intern-hardening** — disables kernel modules before key operations.
- **Smartcard auth** — SSH requires `id_ed25519_sk` and a touch.

## 📐 Per-site variables

| Variable | Meaning |
|---|---|
| `SITE` | Site identifier |
| `SITE_VKEY` | Single-character site key |
| `SITE_UID` | 64-byte hex key for ChaCha20 |
| `ADMIN_ROUTE`, `OFFICE_ROUTE`, `LEGACY_ROUTE` | Network CIDRs |
| `ADMIN_WG_ENDPOINT`, … | WireGuard servers |
| `WG_YUBI_<SITE>_PK`, `_PSK` | PIV object slots |
| `WG_IV` | Per-rekey IV |
| `YUBIKEY_SERIAL` | YubiKey serial |
| `WGDIR`, `KEYGENDIR` | Working directories |
| `MYIP` | Operator WireGuard address |

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../client/README.md">client</a> · <a href="../modules/README.md">modules</a></sub></p>
