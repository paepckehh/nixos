# ⚙️ Siteconfig — Central Infrastructure Configuration

> The single source of truth for site-wide infrastructure values: IDs, domains, networks, shell aliases, and global defaults.

---

## 🗂️ What's In Here

Centralized configuration that all other modules import to get a **consistent view** of the infrastructure topology.

| File | Purpose |
|---|---|
| `config.nix` | **Main infra config** — the primary NixOS expression that exports all infrastructure values |
| `base.nix` | Base site config — infrastructure IDs, network ranges, DNS zones |
| `home.nix` | Home directory & personal infrastructure config |
| `paepcke.nix` | User-specific config for `mpaepcke` (person-level settings) |
| `example.nix` | Example/scaffold config for new sites |
| `sample1.nix` | Sample configuration (dev/testing) |
| `sample2.nix` | Sample configuration (alternative layout) |
| `sample3.nix` | Sample configuration (additional scenario) |
| `smbgate-mounts.nix` | SMB gate mount points configuration |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Old site configurations, deprecated layout variants |

---

## 🚀 How It Works

Siteconfig exports a **structured Nix attrset** that other modules import:

```nix
{ config, pkgs, lib, ... }:
let
  infra = (import ./config.nix).infra;
in {
  # Use infrastructure values
  networking.hostName = infra.hostname;
  networking.networking.interfaces.eth0.ipv4.addresses = [
    {
      address = infra.networks.management.address;
      prefixLength = infra.networks.management.prefix;
    }
  ];
  # ...
}
```

### Config Structure

The `infra` attrset typically contains:
- **`hostname`** — current machine identifier
- **`siteId`** — site/group identifier for multi-location infra
- **`domains`** — DNS domain names and zones
- **`networks`** — Subnet definitions (management, storage, guest, IoT)
- **`users`** — Known user accounts and attributes
- **`ssh`** — SSH host key paths, authorized keys
- **`aliases`** — Shell command aliases for infrastructure ops

---

## 📐 Design Philosophy

- **Single source of truth** — no hardcoded values anywhere
- **Composable** — sample files show how to combine pieces
- **Declarative** — everything is Nix expressions, not shell variables
- **Portable** — swap in a different `config.nix` for a different site

---

## 🔗 Relationships

| Imports From | Purpose |
|---|---|
| `person/*.nix` | User definitions |
| `hosts/*.nix` | Host identity |
| `role/*.nix` | Role capabilities |
| `server/**/*.nix` | Service configurations |
| `hardware/*.nix` | Device settings |

---

*For the full config reference → [config.nix](./config.nix)*
*For host configs → [Hosts](../hosts/)*
