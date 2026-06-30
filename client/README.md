# 🖥️ Client — Machine Setup & Integration

> One machine at a time. WireGuard, backup clients, caching layers, endpoint firewalls, and root CA trust — all declarative.

---

## 🗂️ What's In Here

Client-side NixOS modules for **configuring individual workstations, laptops, and servers** that connect to this infrastructure. Every module is designed to be cherry-picked into any profile's `imports` array.

### Core Modules

| File | Purpose |
|---|---|
| `addWireguard.nix` | WireGuard client setup with automated persistent peers |
| `addBackupClient.nix` | Backup client — pushes host state to backup server |
| `addBackupServer.nix` | Backup server — receives and stores rsync snapshots |
| `addCache.nix` | Nix binary cache client — pulls from NCPS |
| `addCacheUp.nix` | Nix binary cache builder/publisher |
| `addEndlessh.nix` | Endlessh ( SSH honeypot ) for SSH hardening |
| `addOpenSnitch.nix` | OpenSnitch firewall — packet-level application firewall |
| `addOpenSnitch-addDev.nix` | OpenSnitch rules & profiles for dev environments |
| `addOpenSnitch-addSrv.nix` | OpenSnitch rules & profiles for server environments |
| `addUsblock.nix` | USB device blocking via udev rules |
| `addYubilock.nix` | YubiKey-based system lock (suspend-on-remove) |
| `addrootCA.nix` | Root CA certificate trust setup |
| `addrootCA-ext.nix` | Extended root CA (custom extensions) |
| `autoupdate.nix` | Automatic NixOS update scheduling |
| `down.nix` | System shutdown & safe-offline profiles |
| `env.nix` | Global environment variables & PATH configuration |
| `forward-journald.nix` | Systemd journald remote log forwarding |
| `forward-syslog-ng.nix` | Syslog-ng remote forwarding |

### Resources

| Directory | Contents |
|---|---|
| `resources/` | Keyring archives (`.kra`), PGP keys (`.png`) for admin & development PCs |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Legacy client configurations (old wireguard layouts, deprecated modules) |

---

## 🚀 Usage

### Add WireGuard to a Profile

```nix
{
  imports = [
    ./client/addWireguard.nix
  ];

  networking.wireguard.enable = true;
}
```

### Add Backup Client

```nix
{
  imports = [
    ./client/addBackupClient.nix
  ];
}
```

### Deploy Environment Vars

```nix
{
  imports = [
    ./client/env.nix
  ];
}
```

---

## 🔐 Security Notes

- **Endlessh** — SSH honeypot for passive defense; deters brute-force scanning
- **OpenSnitch** — Whitelist-based firewall; only explicitly allowed connections proceed
- **YubiLock** — Physical access defense; system suspends when your YubiKey is removed
- **USB block** — Prevents unauthorized USB storage / HID devices (think: RubberDucky)

---

*For client service modules → [Server](../server/)*
*For root CA certs → [modules/resources/](../modules/resources/)*
