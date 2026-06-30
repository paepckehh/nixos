# 🗄️ .attic — The Digital Graveyard

> Deprecated configs, old flake.lock snapshots, and retired modules — preserved for history, not for use.

---

## 🗂️ What's In Here

Everything **we've stopped using** but can't bear to delete. Think of this as the project's archive — a time capsule of infrastructure evolution.

### Flakes & Configs

| File | Description |
|---|---|
| `flake.nix.20250519` | Old flake.nix from May 2025 — pre-refactor layout |
| `configuration-aarch64.nix` | Former ARM/Native aarch64 configuration (retired) |
| `dynamic-flake.nix` | Old dynamic flake approach (replaced with static flake.nix) |
| `iso-flake.nix` | Previous ISO build approach (now under `storage/`) |
| `local.nix` | Old local development flake configuration |
| `flake-registry.json` | Legacy flake registry (replaced by flake.lock mirrors) |

### Flake Lock Archive

| Directory | Contents |
|---|---|
| `flake.lock/` | **~80+ flake.lock snapshots** — one per flake update from May to June 2026 |

Each `.flake.lock` file is a point-in-time snapshot of the flake dependency graph:

```
2026-05-03-05-30.flake.lock   ← First recorded snapshot
2026-05-13-10-27.flake.lock   ← Mid-May transition
2026-06-07-05-56.flake.lock   ← Early June
2026-06-30-17-46.flake.lock   ← Most recent (now archived)
```

**Why archive lock files?** When something breaks after a flake update, you can `nix-build --flake .$(cat .attic/flake.lock/$(date -d "2026-05-15 05:30").flake.lock)#srv` to pin to a known-good dependency set.

### Archived Subdirectories

| Subdirectory | Contents |
|---|---|
| `.attic/` | Deep archive — old server modules, retired configs |
| `.attic/network/` | Old networking configurations |
| `network/dns.nix` | Legacy DNS setup (moved to `server/dns/`) |
| `network/wifi-duck.nix` | Old WiFi/honeypot config |

### Other Archived Content

| Subdirectory | Contents |
|---|---|
| `server/.attic/` | Old server modules (old Nextcloud, Kimai, Miniflux, Prometheus, Zabbix, etc.) |
| `hardware/.attic/` | Old hardware modules (NVIDIA, AMD legacy, old BIOS configs) |
| `client/.attic/` | Old client modules (WireGuard, autoupdate, forwarding) |
| `modules/.attic/` | Old hardening profiles, retired key providers |
| `user/.attic/` | Old Home Manager configs |
| `packages/.attic/` | Old package definitions |
| `siteconfig/.attic/` | Old site configurations |
| `person/.attic/` | Old person configurations |
| `storage/disko/` | Legacy disko configs (moved to root storage/) |
| `shared/.attic/` | Old shared assets |
| `server/all/.attic/` | Old composite "kitchen sink" modules being gradually split up |

---

## 🚨 Usage Rules

1. **Read-only** — never create new files here
2. **For reference only** — don't import these into active builds
3. **Time-stamped** — flake.lock files encode dates for rollback reference
4. **Preserved** — if it's archived, it was important enough to keep

## 📊 Stats

| Metric | Count |
|---|---|
| Archived flake.lock snapshots | **~82** |
| Archived server modules | **30+** |
| Archived hardware configs | **12+** |
| Archived client modules | **13+** |
| Total archived files | **140+** |

---

*For current server modules → [Server](../server/)*
*For current flake lock → [flake.lock](../flake.lock)*
