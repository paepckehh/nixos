<div align="center">

# 📝 Doc

**Operational notes and agent configuration: SSH, syslog-ng, ZFS, ESP32, Crush.**

[![Notes](https://img.shields.io/badge/runbooks-ssh%20%7C%20syslog%20%7C%20zfs-5277C3)](../doc)
[![Crush](https://img.shields.io/badge/agent-Crush-0891b2)](./crush/init.sh)
[![ESP32](https://img.shields.io/badge/hardware-ESP32-0d9488)](./iot/howto-esp32.md)

`bash doc/crush/init.sh`

</div>

---

## 🗂️ What's in here

| Path | Contents |
|---|---|
| `crush/` | `.crushrc` and `init.sh`, which copies agent configs into `$HOME` |
| `agent/accessibility/` | Accessibility agent notes (`source.txt`) |
| `dns/` | DNS reference (`ff.txt`) |
| `fastfetch/` | `ff.jsonc` system-info theme |
| `generic-unix/` | Hand-me-down Unix config: OpenSSH v9/v10, syslog-ng, moods, RO/RW scripts, authorized_keys |
| `go/` | `go.env` and `go.init.sh` toolchain setup |
| `img/` | NixOS branding images (`nix1.webp`, `nix2.webp`) |
| `iot/` | ESP32 flashing guide |
| `nix/` | `age-systemd-inject.nix` helper |
| `todo/` | Backlog of ideas and candidate services |
| `zfs/` | ZFS operational notes |

There is no `skills/` or `opencode/` directory here. Crush skills live in the
agent's own config tree, not in this repo.

## 🚀 Crush agent config

`doc/crush/init.sh` installs the local Crush configuration:

```bash
bash doc/crush/init.sh
```

It copies `.crushrc` and related files to `$HOME`. Review it before running; it
writes outside the repository.

## 🖥️ Generic Unix

```text
generic-unix/
├── prep-moods.sh                 # prepare mood scripts
├── etc/ssh/sshd_config.openssh-9  # hardened server config
├── etc/ssh/sshd_config.openssh-10 # hardened server config
├── etc/syslog-ng/syslog-ng.conf.init
├── home/me/moods.sh              # mood-based shell setup
├── home/me/ro.sh / rw.sh         # remount root read-only / read-write
├── home/me/.ssh/authorized_keys
└── root/.ssh/authorized_keys
```

These are reference configs, not Nix modules. Copy what you need into a module
instead of sourcing them at runtime.

## 🔗 Related

| Topic | Link |
|---|---|
| ZFS pool docs | [../storage/ZFS.md](../storage/ZFS.md) |
| Backup docs | [../storage/BACKUP.md](../storage/BACKUP.md) |
| IoT devices | [../iot/README.md](../iot/README.md) |
| Main README | [../README.md](../README.md) |

## 📐 Rules

- Notes are reference material; the code is the source of truth.
- Do not store secrets here.
- Keep paths in examples relative to the repo.
- Update notes in the same change that alters the behaviour.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../storage/README.md">storage</a> · <a href="../shared/README.md">shared</a></sub></p>
