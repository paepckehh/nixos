<div align="center">

# 🧩 Server

**The service catalog. One self-contained module per service, one import line to ship it.**

[![Modules](https://img.shields.io/badge/modules-157-5277C3)](../server/all)
[![Categories](https://img.shields.io/badge/categories-58-0891b2)](../server)
[![Nix](https://img.shields.io/badge/all-Nix-7c3aed)](https://nixos.org)
[![Secrets](https://img.shields.io/badge/secrets-51%20sealed-0d9488)](../modules/resources)

`./server/dns/bind.nix`

</div>

---

## 🗂️ What's in here

Every service is one `.nix` module under `server/all/`. The category directories
(`dns/`, `mail/`, `monitoring/`, …) are mostly **symlink views** into `server/all/`;
editing a category file edits its target. Check with `ls -l` before editing.

- **157 live modules** in `server/all/`.
- **58 category directories** under `server/`.
- Commented imports in `flake.nix` are the feature flag: the service stays in the
  catalog, disabled until you uncomment it.
- `srv-full` is the everything-enabled golden build. `srv` is the minimal
  production target.

> `server/all/` also holds near-duplicate variants (`*-container`, `*-docker`,
> `*-authelia`, legacy copies). The flake imports one specific variant; the
> category name does not identify the active implementation.

## 📚 Categories

| Category | Modules | Services |
|---|---|---|
| `dns/` | 15 | Bind, Blocky (resolver + add-ons), Unbound, DNSCrypt, AdGuard, encrypted-dns-server |
| `iam/` | 2 | Authelia SSO, LLDAP directory |
| `pki/` | 4 | step-ca, Certwarden, Mkcertweb, vaultls |
| `ntp/` | 3 | Chrony + Prometheus add-ons |
| `mail/` | 10 | Maddy, Stalwart (2), Roundcube, Davis, Bichon, open-web-calendar, autoconfig |
| `message/` | 3 | Element Web, ntfy, Tuwunel |
| `rss/` | 1 | Miniflux behind Authelia |
| `monitoring/` | 10 | Prometheus, Grafana (2), Loki, Kuma, syslog-ng, Wazuh, exporters, speed |
| `soc/` | 5 | Chef, NetAlertX, Wazuh, web-check, proxy |
| `vpn/` | 3 | Netbird, WireGuard access server, wg-easy |
| `bastion/` | 2 | RDP gateways for admin and user access |
| `rdp/` | 1 | RustDesk |
| `db/` | 6 | MySQL, MongoDB, NocoBase, UNDB, Memcached, Databasement |
| `share/` | 14 | Nextcloud, OpenCloud, OwnCloud, Paperless, Picoshare, Pingvin, Plik, Send, Shifter, SMB gate, Yopass, Zipline, Dumbdrop |
| `storage/` | 1 | ZDash |
| `cloud/` | 2 | Cloud storage, Nextcloud |
| `ai/` | 5 | Ollama, Open WebUI (2), Crush, LibreTranslate |
| `ocr/` | 3 | Paperless-ngx, Paperless-ai, Stirling PDF |
| `search/` | 2 | SearXNG, WebSurfX |
| `translate/` / `lang/` | 1 each | LibreTranslate |
| `office/` | 5 | OnlyOffice (3), BentoPDF, Grist |
| `crm/` | 1 | CRM |
| `erp/` | 1 | ERPNext |
| `hr/` | 2 | TimeOff, Urlaub |
| `ticket/` | 1 | Zammad |
| `time/` | 6 | Kimai (4), TimeTrack (2) |
| `tasks/` / `todo/` | 1 / 2 | DoneTick, Vikunja |
| `virtual/` | 1 | Proxmox |
| `remote/` | 2 | Guacamole, RustDesk |
| `win/` | 2 | Windows start and update helpers |
| `media/` | 2 | Jellyfin, Immich |
| `portal/` | 3 | Homer, Glance, portal-start |
| `cdn/` | 1 | WordPress |
| `devops/` | 5 | Atuin, n8n, OliveTin, OpenVSCode, OnCall |
| `infra/` | 5 | git mirror (container, scripts, updater), NCPS, syslog-ng |
| `opnborg/` | 5 | OpenBorg build and systemd variants |
| `webapp/` | 2 | `res` production, `test` staging |
| `address/` / `api/` / `geo/` | 2 / 2 / 1 | OpenPaq, OSM |
| `lora/` | 1 | Meshtastic Web |
| `wiki/` | 4 | MediaWiki (+LDAP), DocMost, Wiki-Go |
| `bookmarks/` | 1 | Readeck |
| `secret/` | 1 | Vaultwarden |
| `network/` | 2 | Networking toolbox, UniFi |
| `it/` | 3 | Networking toolbox, Rackula, web-check |
| `nixos/` / `builder/` / `cache/` | 1 | NCPS |
| `asset/` | 1 | SnipeIT |
| `server/` | 1 | WebDAV |
| `log/` | 1 | syslog-ng |
| `doc/` | 1 | Stirling PDF |
| `resources/` | 0 | Shared module assets |
| `all/` | 157 | The real modules behind every category |

## 🚀 Use a service

Import the module in a host's `modules` list in `flake.nix`:

```nix
modules = [
  ./server/dns/bind.nix
  ./server/infra/ncps.nix
  ./server/monitoring/prometheus.nix
];
```

Modules read their own `infra` block, so no wiring is needed:

```nix
let infra = (import ../../siteconfig/config.nix).infra;
in {
  services.caddy.virtualHosts."${infra.<service>.fqdn}" = {
    extraConfig = "reverse_proxy 127.0.0.1:${toString infra.<service>.localbind.port.http}";
  };
}
```

## 📐 Rules

- One service, one file, one import, one blast radius.
- Never hardcode an IP or port. Use `infra.<name>.ip` and
  `infra.<name>.localbind.port.http`.
- Secrets live in [`modules/resources/`](../modules/resources), never here.
- A commented import is a documented feature flag, not cleanup debt.
- Format every change with `alejandra`.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../storage/README.md">storage</a> · <a href="../modules/README.md">modules</a></sub></p>
