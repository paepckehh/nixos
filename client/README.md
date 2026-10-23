<div align="center">

# 🖥️ Client

**Client-side modules: WireGuard, caches, firewall, USB blocking, root CA trust.**

[![Modules](https://img.shields.io/badge/modules-17-5277C3)](../client)
[![Flexible](https://img.shields.io/badge/import-cherry%20pick-0891b2)](../client)
[![Nix](https://img.shields.io/badge/plain%20Nix-modules-0d9488)](https://nixos.org)

`imports = [ ./client/addWireguard.nix ];`

</div>

---

## 🗂️ What's in here

| File | Purpose |
|---|---|
| `addWireguard.nix` | WireGuard client with persistent peers |
| `addCache.nix` | Nix binary cache client pointing at NCPS |
| `addCacheUp.nix` | Binary cache builder and publisher |
| `addEndlessh.nix` | SSH honeypot |
| `addOpenSnitch.nix` | Application-level packet firewall |
| `addOpenSnitch-addDev.nix` | OpenSnitch rules for dev machines |
| `addOpenSnitch-addSrv.nix` | OpenSnitch rules for servers |
| `addUsblock.nix` | USB device blocking via udev |
| `addYubilock.nix` | Suspend when the YubiKey is removed |
| `addrootCA.nix` | Root CA trust |
| `addrootCA-ext.nix` | Extended root CA setup |
| `addHomeFix.nix` | Home permission and ownership fixes |
| `autoupdate.nix` | Scheduled NixOS updates |
| `down.nix` | Safe shutdown and offline profiles |
| `env.nix` | Global environment variables and PATH |
| `forward-journald.nix` | Remote journald forwarding |
| `forward-syslog-ng.nix` | Remote syslog-ng forwarding |

`resources/` holds keyring archives (`.kra`) and avatars for admin and office
machines. `.attic/` holds retired client layouts.

## 🚀 Use a module

```nix
{
  imports = [
    ./client/env.nix
    ./client/addWireguard.nix
    ./client/addCache.nix
    ./client/addrootCA.nix
  ];
}
```

Modules are independent. Import only what the machine needs; each one sets its
own options and does not assume a role or a host.

## 🔐 Security notes

- **Endlessh** — passive SSH defense; slows down scanners.
- **OpenSnitch** — default-deny outbound connections; allow explicitly.
- **YubiLock** — physical-presence lock; removal suspends the machine.
- **USB block** — stops unauthorized storage and HID devices.
- **root CA** — trust the internal CA and nothing you cannot name.

## 📐 Rules

- No host identity, no site values. Read `infra` yourself if a module needs it.
- Keep modules cherry-pickable; do not add hidden cross-imports.
- Never place plaintext key material in `resources/`.
- Format with `alejandra`.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../user/README.md">user</a> · <a href="../modules/README.md">modules</a></sub></p>
