# -= WARNING =-

This repo is for rapid prototyping, wild tests.
Feel free to copy code, take inspiration.  
Do not use anything in production without review!

# Company as a Service
# Your Company Infrastructure (Server, Services, Cloud, Client and Network) managed via one unified NixOS Repo.

# Manage Nixos via make (requires pkgs.gnumake)

| Target | Description |
|--------|-------------|
| `make switch` | Switch to a new boot profile for the current host/profile |
| `make boot` | Build a new boot profile (alias for `build`) |
| `make build` | Build but don't switch |
| `make update` | Update `flake.lock` from upstream repos |
| `make clean` | Garbage collect old profiles (>12 days), then rebuild |
| `make clean-profiles` | Remove all boot profiles, then build a clean one |
| `make check` | Type-check / build without installing |
| `make rollback` | Rollback to the previous generation |
| `make gc` | Garbage collect old generations (>12 days) |
| `make world` | Full update + switch + garbage collect |
| `make sdb` | Build install image for target disk `/dev/sdb` |

Chainable: `make update switch` or `make [TAB]` to discover all options.

### Cross-Profile & Encrypted Builds

```bash
# Build for a different target OS profile
TARGET=client make build
TARGET=kiosk make build

# Full-disk encryption (LUKS)
make LUKS='secret' sdb

# Custom config path
CONFIG_PATH=./some-config.nix make build
```

## NixOS Direct

```bash
nixos-rebuild switch --flake .#<profile-name>
nixos-rebuild build --flake .#<profile-name>
nix flake check           # Run checks (if defined)
nixos-option -r <option>  # Lookup a system option
```

## Code Quality

```bash
make pre-commit   # alejandra formatting + git add
alejandra --quiet .  # format entire repo
```

## Profiles & Boot Targets

| Profile | Description |
|---------|-------------|
| `srv` | Full server — ADM + server roles, stateless + LUKS |
| `kiosk` | Kiosk desktop — stateless root, no encryption |
| `internet` | Internet browser desktop — stateless + LUKS |

## Service Categories

| Category | Contents |
|----------|----------|
| `server/dns/` | Bind DNS, AdGuard, Blocky, Unbound, DNSCrypt |
| `server/iam/` | Authelia (OIDC/JWT), LLDAP (LDAP/SCIM) |
| `server/mail/` | Maddy (MTA), Roundcube (IMAP), Davis, Bichon |
| `server/monitoring/` | Prometheus, Grafana, Loki, Kuma, Syslog-ng |
| `server/share/` | Nextcloud, OpenCloud, Paperless, Picoshare |
| `server/storage/` | ZFS dash (zdash) |
| `server/db/` | MySQL, MongoDB, Memcached, UniD, NocoBase |
| `server/pki/` | Small-step CA, Certwarden, Mkcertweb |
| `server/office/` | OnlyOffice |
| `server/ocr/` | Paperless, Paperless-ngx, Paperless-ai |
| `server/ai/` | Ollama, Open Web UI |
| `server/media/` | Jellyfin, Immich |
| `server/search/` | SearX, WebSurfX |
| `server/time/` | Kimai (timetracking) |
| `server/soc/` | Chef, NetAlertX, Wazuh |
| `openwrt/` | OpenWRT router configs (Axt, Glinet, RPi, D-Link) |
| `iot/` | IoT device configs (DAB, Ecoflow, HomeAssistant) |
| `guard/` | OpenWRT/ESP32 security guard configs |

## Secrets

- Stored as `.age` encrypted files in `modules/resources/`
- Managed via **[agenix](https://github.com/ryantm/agenix)**
- Each service typically has its own `.age` file (e.g. `lldap-admin.age`, `vault.age`)
- Identity uses SSH keys: `/nix/persist/etc/ssh/ssh_host_ed25519_key`

## State & Persistence

- **Stateless root** (`/` is tmpfs) — all persistent data is stored under `/nix/persist`

## Additional Documentation

- [Storage / ZFS](./storage/ZFS.md)
- [Storage / Backup](./storage/BACKUP.md)
- [Guard README](./guard/README.md)
- [OpenWRT README](./openwrt/README.md)
