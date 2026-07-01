# Admin WireGuard SSH Key Configuration System

## Overview

This is a hardened, YubiKey-backed WireGuard key management and VPN access system
for NixOS-based infrastructure. It provisions WireGuard private keys, pre-shared
keys, and public keys by storing them encrypted on a YubiKey (PIV applet), then
assembles temporary in-memory WireGuard configurations to connect to one of
three site networks: admin, office, or legacy.

```
┌──────────┐   SSH ed25519-sk    ┌──────────────────┐    YubiKey PIV    ┌──────────┐
│ Operator │◄──────────────────► │ This System      │◄─────────────────►│ YubiKey  │
│ (laptop) │  + wormhole tunnels │ (/etc/nixos/     │  Export/import    │ (0x5fc*) │
│          │►───────────────────►│ admin/)          │                   │          │
└──────────┘  port forwards      └──────────────────┘    Encrypt        └──────────┘
                    │                       │
                    │  wg-quick (tmpfs)     │  WireGuard server
                    ▼                       ▼
             ┌─────────────┐        ┌──────────────┐
             │ Admin net   │        │ WireGuard    │
             │ 10.20.0.0   │        │ endpoint     │
             └─────────────┘        └──────────────┘
```

## Prerequisites

| Dependency | Purpose |
|---|---|
| `gnumake` (pkgs.gnumake) | Orchestration via the Makefiles |
| `wireguard-tools` (pkgs.wg-wireguard-tools) | `wg` and `wg-quick` CLI |
| `yubikey-manager` (pkgs.yubikey-manager) | Key import/export to YubiKey PIV objects |
| `openssl` | ChaCha20 encryption / SHA3 entropy |
| YubiKey with PIV applet configured | Secure key storage (slots `0x5fc110`–`0x5fc115`) |

## Architecture

The system is organised as a chain of Makefiles:

```
Makefile.Site.<NAME>     # Site-specific: IPs, routes, YubiKey slots, TIDs
       │
       ▼
Makefile.Generic         # Core logic: rekey (keygen/import), start/stop routing,
       │                  SSH + wormhole tunnels, log helpers
       ▼
keygen.sh                # Standalone script: generates WireGuard key triples
                         # (private key, pre-shared key, public key) with
                         # custom entropy-mixing
```

### Sites

| Site          | Route           | WG Endpoint              | WG Net      | PIV slots           |
|---------------|-----------------|--------------------------|-------------|---------------------|
| `ADMIN`       | `10.20.0.0/23`  | `178.13.0.208:51821`     | `10.20.60` | PK:`0x5fc110` PSK:`0x5fc111` |
| `OFFICE`      | `10.20.6.0/23`  | `178.13.0.208:51820`     | `10.20.66` | PK:`0x5fc112` PSK:`0x5fc113` |
| `LEGACY`      | `192.168.22.0/24`| `178.13.0.208:51822`    | `10.20.62` | PK:`0x5fc114` PSK:`0x5fc115` |

## Workflows

### 1. Generate & provision a new set of WireGuard keys

```bash
# Generate keys (private, pre-shared, public) — writes to KEYGENDIR
make yubikey.rekey.admin     # or .office / .legacy

# Steps:
#   rekey.keygen  → keygen.sh creates unencrypted .pk, .psk, .pub in ~/.wg/
#   rekey.import  → encrypts .pk/.psk with ChaCha20 (KEY=SITE_UID, IV=8-byte),
#                   imports them into the YubiKey PIV slots, then prints the
#                   cleartext .psk and .pub for configuration on the WG server
```

The keygen script uses a custom `gen_key_triple` routine that exercises the
prNG seed (`init_urand`) and a verification character loop before writing key
triples to the working directory.

### 2. Connect the WireGuard tunnel

```bash
# Start the tunnel (auto-provisions config, retrieves keys from YubiKey,
# mounts a tmpfs for plaintext keys at runtime, unmounts on disconnect)
make wg-start-admin
#   or .office / .legacy

# Stop the tunnel
make wg-stop-admin
#   or .office / .legacy
```

The connection flow:

1. Checks SSH agent has the smartcard key (`ADMIN_SSH_SMARTCARD`).
2. Verifies the route does not already exist.
3. Creates a temporary WireGuard config at `~/.keyguard-<SITE>/(admin|office|legacy).conf`.
4. Mounts `tmpfs` at the `keys-<SITE>` subdirectory (mode 0700) — keys never touch disk.
5. Decrypts keys from the YubiKey PIV objects at runtime and feeds them to `wg set`.
6. Brings up the interface with `wg-quick`.
7. Disconnecting unmounts the tmpfs, destroying all plaintext keys.

### 3. Access services through the tunnel

| Target   | Make target          | What it does                                    |
|----------|----------------------|-------------------------------------------------|
| SSH ops  | `ssh.ops` … `ssh.ops8`  | SSH tunnel to an ops machine (`TID`) on port 6623 |
| SSH borg | `ssh.borg01` … `ssh.borg15` | SSH tunnel to a borg machine on port 6622    |
| Web ui   | `adguard`, `unifi`, `forgejo`, `opnborg`, `prometheus` | Port-forward via SSH wormhole + auto-open in browser |
| Borg web | `borg01` … `borg15`  | Port-forward to borg web interface (80)            |
| Logs     | `log.console`, `log.hostwatch`, `log.newstation` | SSH + tail to syslog-ng output, piped through bat |
| Crush    | `crush`              | SSH tunnel with op ssh to the crush box            |
| Skynet   | `skynet`             | SSH tunnel to skynet                               |

The `ssh` targets and tunnel targets both confirm route readiness (with a
progress spinner and `ping` check) before attempting the connection, and prompt
the operator to touch their YubiKey at the right moment.

### 4. Manage routes

```bash
make kill.routes    # Removes all admin, office, and legacy routes
make wg-status      # Runs `sudo wg show`
```

## Directory layout

```
/etc/nixos/admin/
├── Makefile.Site.<NAME>    # Site definitions (IPs, slots, ports, TIDs)
├── Makefile.Generic        # Core orchestration: rekey, wg start/stop, tunnels
├── Makefile.Example        # Template for new sites
└── keygen.sh               # Standalone WireGuard key-triple generator

~/.wg/                      # Working directory for key material (tmpfs, ephemeral)
~/.keyguard-<SITE>/         # WireGuard config files
    └── keys-<SITE>/        # Volatile tmpfs — lives in RAM only
```

## Security model

- **YubiKey PIV storage** — Only encrypted key blobs reside on the YubiKey.
  Plaintext key material never persists on disk; it is decrypted on-demand into
  a tmpfs mount, used, then immediately destroyed.
- **ChaCha20 encryption** — Keys are encrypted with the site-wide `SITE_UID`
  (64-byte SHA3-512 derived) and a per-rekey 32-byte SHA3-512 IV.
- **TMPFS isolation** — The `keys-<SITE>` directory is a `tmpfs` mount
  (`mode 0700`), ensuring keys exist solely in RAM.
- **Module hardening** — `intern-hardening` disables kernel modules before
  key operations to reduce attack surface.
- **Smartcard auth** — SSH connections require the operator's SSH smartcard key
  (`id_ed25519_sk`) for mutual authentication.
- **Route validation** — The system refuses to start a tunnel if the route
  already exists (prevents duplicates) and cleans up on stop.

## Per-site variables

| Variable              | Description                        |
|-----------------------|------------------------------------|
| `SITE`               | Site identifier (e.g. `DEBICLOUD`) |
| `SITE_VKEY`          | Single-character site key          |
| `SITE_UID`           | 64-byte hex key (ChaCha20 key)     |
| `ADMIN_ROUTE` / `OFFICE_ROUTE` / `LEGACY_ROUTE` | Network CIDR |
| `ADMIN_NET` / `OFFICE_NET` / `LEGACY_NET` | WireGuard subnet prefix |
| `ADMIN_WG_ENDPOINT` / `OFFICE_WG_ENDPOINT` / `LEGACY_WG_ENDPOINT` | Remote WG server |
| `WG_YUBI_<SITE>_PK` / `_PSK` | YubiKey PIV object slots   |
| `WG_IV`              | 32-byte IV for key encryption      |
| `YUBIKEY_SERIAL`     | YubiKey serial number              |
| `WGDIR`              | Working directory for WG config    |
| `KEYGENDIR`          | Working directory for keygen output|
| `MYIP`               | Operator's WireGuard IP address    |
