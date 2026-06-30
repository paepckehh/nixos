# 🏠 Hosts — Per-Machine NixOS Configurations

> The top-level declarations that stack every module together for each physical server.

---

## 🗂️ What's In Here

Each file is a **complete NixOS configuration for one physical server**. They're the final stacking layer that glues together hardware modules, storage layouts, server services, and host-specific overrides.

| File | Purpose |
|---|---|
| `srv.nix` | **Primary server** — full production build with admins, services, stateless+LUKS storage |
| `srv2.nix` | **Secondary server** — alternate storage layout, devops services, GNOME desktop |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Previous versions & decommissioned host configs |

---

## 🚀 How Hosts Work

Each host file follows a **modular stacking pattern**:

```nix
{ config, pkgs, ... }:
let
  infra = (import ../siteconfig/config.nix).infra;
in {
  imports = [
    # Hardware
    ../hardware/all.nix
    ../hardware/amd.nix

    # Storage
    ../storage/zfs.nix

    # Services
    ../server/dns/bind.nix
    ../server/mail/maddy-admin.nix
    ../server/monitoring/prometheus.nix

    # Roles & users
    ../role/adm.nix
    ../person/mpaepcke.nix
  ];

  # Host-specific overrides
  networking.hostName = "srv";
  networking.interfaces.eno1.ipv4.addresses = [ ... ];
}
```

**Key files it depends on:**

| Dependency | Role |
|---|---|
| `../siteconfig/config.nix` | Centralized infrastructure config (IDs, domains, network) |
| `../hardware/*.nix` | CPU/GPU/firmware settings |
| `../storage/*.nix` | Disk layout, partitions, ZFS pools |
| `../server/**/*.nix` | Service modules |
| `../role/*.nix` | Admin/server role definitions |
| `../person/*.nix` | Per-user configurations |

---

## 🔧 Build Targets

```bash
# Build & deploy to srv
TARGET=srv make boot

# Rollback if something breaks
make rollback
```

---

*For service definitions → [Server](../server/)*
*For site config → [Siteconfig](../siteconfig/)*
