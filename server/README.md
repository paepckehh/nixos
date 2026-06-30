# ⚡ Server — 355+ Service Modules

> Your entire infrastructure as declarative NixOS modules. **40+ categories. Zero Terraform. All Nix.**

---

## 🗂️ What's In Here

This is the **beating heart** of the infrastructure — every service lives here as a self-contained `.nix` module.
Think of it as a feature catalog: commented-out services are the "all-you-can-order menu" for `srv-full` that you can uncomment to ship.

### Core Infrastructure 🔧

| Category | Modules | Services |
|---|---|---|
| `dns/` | 13 | Bind (primary DNS), Blocky (ad-blocking resolver), Unbound (stub resolver), DNSCrypt-proxy, AdGuard, encrypted-dns-server |
| `iam/` | 2 | Authelia (OIDC/JWT SSO w/ PassKey), LLDAP (LDAP/SCIM directory) |
| `pki/` | 5 | Small-step CA, Certwarden, Mkcertweb, vaultls — full PKI lifecycle from cert auth to auto-renewal |
| `ntp/` | 3 | Chrony (NTP server w/ Prometheus metrics) |
| `sip/` | 1 | Coturn (STUN/TURN for VoIP & WebRTC) |

### Mail & Communication 💌

| Category | Modules | Services |
|---|---|---|
| `mail/` | 10 | Maddy (MTA), Stalwart (Rust-based mail suite), Roundcube (webmail), Davis (ticketing), Bichon, open-web-calendar, autoconfig (IMAP/SMTP) |
| `message/` | 3 | Element Web (Matrix client), NTFY (pub/sub notifications), Tuwunel |
| `rss/` | 1 | Miniflux (RSS reader w/ Authelia protection) |

### Monitoring & Security 🛡️

| Category | Modules | Services |
|---|---|---|
| `monitoring/` | 10 | Prometheus, Grafana (2 instances), Loki (logs), Kuma (logs UI), Syslog-ng, Wazuh EDR, prometheus-exporter, prometheus-opnsense, speed test |
| `soc/` | 5 | Chef (SOC orchestration), NetAlertX, Wazuh (SIEM), Web-check, proxy |
| `vpn/` | 3 | Netbird (mesh VPN), Wg-Access-Server, Wg-Easy (WireGuard) |
| `bastion/` | 2 | RDP gateways for admin & user access |

### Data & Storage 💾

| Category | Modules | Services |
|---|---|---|
| `db/` | 6 | MySQL, MongoDB, NocoBase (no-code DB), UniD/UNDB (database), Memcached, DatabaseMent |
| `share/` | 14 | Nextcloud (2 variants), OpenCloud, OwnCloud, Paperless, Picoshare, Shifter, Pingvin/Send file drops, Yopass (secret sharing), Zipline, Dumbdrop, Smbgate |
| `storage/` | 1 | ZDash (ZFS dashboard) |

### AI & Intelligence 🤖

| Category | Modules | Services |
|---|---|---|
| `ai/` | 5 | Ollama (local LLM runtime), Open Web UI (2 variants), Crush (the AI that wrote this repo), translate-llm |

### OCR, Search & Documents 📄

| Category | Modules | Services |
|---|---|---|
| `ocr/` | 3 | Paperless-ngx (document mgmt), Paperless-ai (LLM-powered OCR), Stirling PDF |
| `search/` | 2 | SearXNG, WebSurfX |

### Business Apps 🏢

| Category | Modules | Services |
|---|---|---|
| `office/` | 5 | OnlyOffice (3 variants), Bentopdf (PDF gen), Grist (spreadsheets-as-apps) |
| `crm/` | 1 | CRM system |
| `erp/` | 1 | ERPNext |
| `hr/` | 2 | TimeOff, Urlaub (time-off management) |
| `ticket/` | 1 | Zammad (helpdesk/ticketing) |
| `time/` | 5 | Kimai (3 variants), TimeTrack (2) |
| `tasks/` | 1 | DoneTick (task management) |
| `todo/` | 2 | DoneTick, Vikunja (task app w/ Authelia) |

### Virtualization & Remote Access 🖥️

| Category | Modules | Services |
|---|---|---|
| `virtual/` | 1 | Proxmox (hypervisor) |
| `remote/` | 1 | Guacamole (HTML5 RDP/VNC gateway) |
| `win/` | 2 | Windows update/start helpers for VM management |

### Media & Content 🎬

| Category | Modules | Services |
|---|---|---|
| `media/` | 2 | Jellyfin (media server), Immich (2 — photo backup + Authelia variant) |
| `portal/` | 3 | Homer (static dashboard), Glance (aggregated feed dashboard), Homer it |
| `cdn/` | 1 | WordPress CDN |

### Developer & DevOps Tools 🛠️

| Category | Modules | Services |
|---|---|---|
| `devops/` | 5 | Atuin (shell history), N8n (workflow automation), OliveTin (UI for shell commands), OpenVSCode Server, OnCall (scheduling) |
| `infra/` | 5 | Git mirror runner, Git mirror container, Git mirror updater, NCPS, Syslog-ng |
| `opnborg/` | 5 | OpenBorg (distributed build system) |
| `webapp/` | 2 | `res` (production), `test` (staging) |

### Translation & Libraries 🌍

| Category | Modules | Services |
|---|---|---|
| `translate/` | 1 | LibreTranslate (self-hosted translation API) |
| `lang/` | 1 | LibreTranslate |

### Smart Home & IoT 🏠

| Category | Modules | Services |
|---|---|---|
| `lora/` | 1 | Meshtastic-Web (LoRa mesh networking dashboard) |

### Wikis & Extras 📚

| Category | Modules | Services |
|---|---|---|
| `wiki/` | 5 | MediaWiki, MediaWiki+LDAP, DocMost, WikiGo, wiki-go-docker |
| `bookmarks/` | 1 | Readeck (read-it-later / bookmark manager) |
| `secret/` | 1 | Vaultwarden (self-hosted Bitwarden) |
| `network/` | 2 | Networking toolbox, UniFi controller |
| `it/` | 3 | Networking toolbox, Rackula, Web-check |
| `nixos/` | 1 | NixOS-specific configuration module |
| `server` | 1 | WebDAV server |
| `log/` | 1 | Syslog-ng |
| `cloud/` | 2 | Cloud storage, Nextcloud |
| `builder/` | 1 | NCPS builder |
| `asset/` | 1 | SnipeIT (asset management) |
| `all/` | 200+ | Legacy & composite modules — the old monolith being gradually split up |

---

## 🚀 How It Works

Each service is a **self-contained NixOS module** — import into a profile's `modules` list in `flake.nix` to activate:

```nix
{
  imports = [
    ./server/dns/bind.nix
    ./server/mail/maddy-admin.nix
    ./server/monitoring/prometheus.nix
  ];
}
```

**Service discovery** via Nixpkgs `config` attribute means you can query `man configuration.nix` for any service's available options.

**Feature flagging via commenting**: in `srv-full`, services that are `# commented out` are available but disabled — a visual catalog of the entire infrastructure's capabilities.

---

## 💡 Design Philosophy

- **One module per service** — each `.nix` file is independently importable
- **Decoupled secrets** — `.age` files live in `modules/resources/` not here
- **Comment = disabled** — nothing gets deleted, only greyed out
- **355 modules** across 40+ categories, each independently activatable

> **Note**: The `all/` subdirectory contains legacy composite modules being gradually split into the granular categories above.

---

*For secrets management → [modules/](../modules/)*
*For service categories → [Main README](../README.md)*
