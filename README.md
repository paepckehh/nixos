
> Your entire company — server, services, cloud, client, and network — managed through a single NixOS configuration repo. 355+ NixOS modules across 50+ service categories. Stateless root, declarative deployments, secrets via agenix + YubiKey.

## Table of Contents

- [Architecture](#architecture)
- [Directory Layout](#directory-layout)
- [Profiles](#profiles)
- [Services](#services)
- [Development Workflow](#development-workflow)
- [Secrets](#secrets)
- [Design Philosophy](#design-philosophy)
- [Additional Documentation](#additional-documentation)

## Architecture

```
flake.nix                    ← Entry point: defines all nixosConfigurations
├── configuration.nix        ← Global defaults (Nix, boot, security, network, users)
├── siteconfig/config.nix    ← Centralized infra config (IDs, domains, shell aliases, kernel params)
├── modules/                 ← Custom & nixpkgs modules (hardening, SOPS/agenix, logging)
├── hardware/                ← Hardware-specific modules (amd, intel, all)
├── storage/                 ← Disk layouts (stateless, stateless-luks, zfs, ISO, auto-installer)
├── hosts/                   ← Host-specific overrides
├── role/                    ← Role profiles (adm, server)
├── person/                  ← Per-user configurations
├── user/                    ← Home Manager configurations
├── packages/                ← Package collections (base, devops, desktop)
├── server/                  ← 355+ service definitions, organized by category (see below)
├── client/                  ← Client-side configs (wireguard, caches, backup, rootCA)
├── iot/                     ← IoT device configs (DAB, Ecoflow, HomeAssistant, Tibber, Moode)
├── openwrt/                 ← Router configs (Glinet, D-Link, RPi, AXT)
├── guard/                   ← OpenWRT/ESP32 security guard configs
├── shared/                  ← Shared assets (branding, YARA rules, repo scripts)
└── doc/                     ← Documentation (ZFS notes, TODO, fastfetch config, images)
```

Each service is a self-contained NixOS module. Import into a profile's `modules` list in `flake.nix` to activate.

## Directory Layout

| Path | Purpose |
|---|---|
| `flake.nix` | Flake entry point with all NixOS configurations |
| `configuration.nix` | Global defaults for all profiles |
| `siteconfig/config.nix` | Centralized infrastructure config (site ID, domains, users, kernel params) |
| `modules/` | NixOS modules (hardening, SOPS/agenix, logging) |
| `hardware/` | Hardware-specific modules per device type |
| `storage/` | Disk layouts (disko-based: stateless, stateless-luks, zfs, ISO, auto-installer) |
| `hosts/` | Host-specific configuration overrides |
| `role/` | Role-based profiles (admin, server) |
| `person/` | Per-user personal configs |
| `user/` | Home Manager user-level configs |
| `packages/` | Package collections (base, devops, desktop, devops-*) |
| `server/` | 355+ service definitions, organized by category |
| `client/` | Client configurations (backup, wireguard, caches, rootCA) |
| `iot/` | IoT device configs |
| `openwrt/` | OpenWRT router configurations |
| `guard/` | OpenWRT/ESP32 security guard |
| `shared/` | Shared assets (branding, YARA rules, repo scripts) |
| `doc/` | Documentation and reference material |
| `.attic/` | Archived/deprecated configurations and old flake.lock snapshots |

## Profiles

| Profile | Description |
|---|---|
| **`srv`** | Full server — admin + server roles, stateless root + LUKS |
| **`srv2`** | Secondary server alternate build (different storage layout) |
| **`srv-full`** | Complete server with all services enabled (used for full builds) |
| **`kiosk`** | Kiosk desktop — stateless root, no encryption |
| **`internet`** | Internet browsing desktop — stateless root + LUKS |
| **`client`** | Generic client workstation |
| **`iso`** | NixOS live ISO image |
| **`iso-installer`** | Automated disk-installer ISO using disko |

Build for a different target: `TARGET=<profile> make build`

## Services

355+ NixOS modules organized into 50+ categories:

| Category | Services |
|---|---|
| `dns/` | Bind, Blocky, Unbound, DNSCrypt, AdGuard |
| `iam/` | Authelia (OIDC/JWT), LLDAP (LDAP/SCIM) |
| `mail/` | Maddy (MTA), Roundcube, Davis, Bichon, open-web-calendar |
| `monitoring/` | Prometheus, Grafana, Loki, Kuma, Syslog-ng |
| `share/` | Nextcloud, OpenCloud, OwnCloud, Paperless, Picoshare, Shifter, Send, Pling, Yopass, Zipline, Dumbdrop, Smbgate |
| `db/` | MySQL, MongoDB, NocoBase, UniD, Memcached, DatabaseMent |
| `pki/` | Small-step CA, Certwarden, Mkcertweb, Vaultls |
| `ai/` | Ollama, Open Web UI |
| `media/` | Jellyfin, Immich |
| `search/` | SearX, WebSurfX |
| `ocr/` | Paperless, Paperless-ngx, Paperless-ai, Stirling |
| `secret/` | Vaultwarden |
| `time/` | Kimai, TimeTrack |
| `soc/` | Wazuh, NetAlertX, Chef (SOC orchestration) |
| `cloud/` | Cloud infrastructure, Nextcloud |
| `vpn/` | Netbird, Wg-Access-Server, Wg-Easy |
| `backup/` | Backup infrastructure |
| `bastion/` | RDP gateways (admin + user) |
| `bookmarks/` | Readeck |
| `builder/` | Nix binary cache (ncps) |
| `cdn/` | WordPress CDN |
| `crm/` | CRM system |
| `devops/` | Atuin, N8n, OliveTin, OpenVS-Code, OnCall |
| `erp/` | ERPNext |
| `hr/` | TimeOff, Urlaub |
| `infra/` | Git mirror, Syslog-ng, NCPS |
| `it/` | Networking toolbox, Rackula, WebCheck |
| `lang/` | LibreTranslate |
| `log/` | Syslog-ng |
| `lora/` | Meshtastic-Web |
| `ntp/` | Chrony |
| `office/` | OnlyOffice |
| `opnborg/` | OpenBorg |
| `portal/` | Glance, Homer |
| `remote/` | Guacamole |
| `rss/` | Miniflux |
| `sip/` | Coturn |
| `storage/` | ZDash |
| `tasks/` | DoneTick |
| `ticket/` | Zammad |
| `translate/` | LibreTranslate |
| `virtual/` | Proxmox |
| `webapp/` | Web applications (res, test) |
| `wiki/` | DocMost, MediaWiki |
| `win/` | Windows update/start helpers |

Services marked with `#` in `flake.nix`'s `srv-full` profile are declared but disabled — uncomment to enable.

## Development Workflow

```bash
make switch          # Build + deploy to current host
make boot            # Build + reboot (alias for build)
make build           # Build only (no deploy)
make check           # Type-check / dry-run (includes alejandra formatting)
make rollback        # Roll back to previous generation
make gc              # Garbage collect >12 day old generations
make clean           # Clean old profiles + rebuild
make world           # Update + switch + GC in one run
make sdb             # Build install image for /dev/sdb
make clean-profiles  # Remove all boot profiles + rebuild

# NixOS direct
nixos-rebuild switch --flake .#srv
nix flake check
nix flake update     # Update flake.lock from upstream

# Formatting
make pre-commit      # Run alejandra + git add
alejandra --quiet .  # Format the entire repo
```

Target a different profile: `TARGET=kiosk make build`

## Secrets

Secrets are managed via **[agenix](https://github.com/ryantm/agenix)** with YubiKey-based key derivation.

- All `.age` encrypted files live in `modules/resources/`
- Each service has its own secret file (e.g., `lldap-admin.age`, `vault.age`, `bind.age`)
- Hardware keys (YubiKey) are used via `age-plugin-yubikey`
- SSH host keys persist at `/nix/persist/etc/ssh/`
- Never edit `.age` files directly — use `paper-age` or the agenix decryption process

## Design Philosophy

- **Stateless root** — `/` is tmpfs; all persistent data goes under `/nix/persist`
- **Declarative** — the entire system state is version-controlled and reproducible
- **Modular** — 355+ service modules, each independently importable
- **Secure by default** — hardened kernel params, AppArmor, locked modules, restricted sysctl
- **Git-mirrored flakes** — upstream flake inputs are proxied through a local git mirror (`git-mirror.home.corp`) for offline/air-gapped builds
- **Progressive disclosure** — the `srv-full` profile has all services listed; active services are uncommented, inactive ones stay visible as a feature catalog

```
┌─────────────╮     ┌───────────────╮     ┌──────────────╮
│  flake.nix  │────>│ config.nix    │────>│  profiles    │
│  (entry)    │     │ (site config) │     │ (srv, kiosk) │
└─────────────┘     └───────────────┘     └──────────────┘
       │                                      │
       │         ┌───────────────┐            │
       ├────>    │  modules/     │            │
       │         │ (hardening,   │            │
       │         │  SOPS/agenix) │            │
       │         └───────────────┘            │
       │                                      │
       │      ┌───────────────┐               │
       └────>│  server/       │<──────────────┘
             │  (355+ services)│
             └───────────────┘
```

## Additional Documentation

- [Storage / ZFS](./storage/ZFS.md)
- [Storage / Backup](./storage/BACKUP.md)
- [Guard README](./guard/README.md)
- [OpenWRT README](./openwrt/README.md)
