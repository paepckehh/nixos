# 📝 Doc — Knowledge Base & Tooling Documentation

> The project's brain: ESP32 how-tos, Crush AI skills, theme factory, Nix helpers, and operational runbooks.

---

## 🔥 What's In Here

Everything that doesn't fit neatly into a service module — documentation, how-tos, AI agent configs, skills, and operational knowledge.

### 🗂️ Directory Structure

| Directory | Contents |
|---|---|
| `crush/` | AI agent configs — **Crush skills** (Go linting, testing, Golang conventions, frontend design, theme factory, skill creation, web artifacts) |
| `skills/` | Standalone skill packages — algorithmic art, web testing, frontend design, theme factory, web artifacts |
| `zfs/` | ZFS operational notes — pool creation, property tuning, troubleshooting |
| `iot/` | ESP32 IoT how-to guide — flashing, provisioning, mesh setup |
| `todo/` | Active task & feature list |
| `nix/` | Nix snippets — `age-systemd-inject.nix` helper |
| `dns/` | DNS-related reference notes |
| `generic-unix/` | Generic Unix prep scripts, SSH configs, shell scripts for moods & dotfiles |
| `fastfetch/` | `ff.jsonc` — system info display config |
| `opencode/` | `opencode.jsonc` — OpenCode IDE config |
| `img/` | Images — NixOS branding assets |

### 🤖 Crush AI Skills

Deep directory with Go-specific skill definitions:

| Skill | Purpose |
|---|---|
| `go-control-flow/` | Conditionals, loops, guards, switch patterns |
| `go-error-handling/` | Wrapping, custom error types, fmt.Errorf patterns |
| `go-functional-options/` | Optional params, functional constructors |
| `go-documentation/` | Doc comments, godoc conventions |
| `go-code-review/` | Review templates, pre-review checklist |
| `go-data-structures/` | Slices, maps, allocation patterns |
| `go-generics/` | Type constraints, aliases vs definitions |
| `go-functions/` | Function signatures, return values, naming |
| `go-declarations/` | Variables, const, iota, struct design |
| `go-linting/` | golangci-lint setup, check configs |
| `go-interfaces/` | Interface design, embedding, type assertions |
| `go-testing/` | Table-driven tests, subtests, assertions |
| `go-style-core/` | Formatting, line length, nesting rules |
| `go-performance/` | Optimization, string handling, benchmarking |
| `go-context/` | context.Context placement, cancellation, deadlines |
| `go-concurrency/` | Goroutines, channels, mutexes, sync primitives |
| `go-naming/` | Identifier naming, package naming conventions |
| `go-logging/` | slog setup, log levels, structured logging |
| `go-packages/` | Package organization, import management |

Plus the general-purpose skills:

| Skill | Purpose |
|---|---|
| `algorithmic-art/` | p5.js generative art, seeded randomness |
| `webapp-testing/` | Playwright browser automation |
| `web-artifacts-builder/` | React + Tailwind + shadcn/ui artifact generation |
| `frontend-design/` | UI aesthetic direction, typography, design patterns |
| `theme-factory/` | 10 curated color themes for any artifact (arctic-frost, sunset-boulevard, etc.) |
| `internal-comms/` | Status reports, newsletters, FAQ answers, 3P updates |
| `skill-creator/` | Create & evaluate new skills, benchmarking, schema validation |

### 🏠 IoT

| File | Purpose |
|---|---|
| `iot/howto-esp32.md` | ESP32 flash, provision, and mesh networking guide |

### 📊 ZFS

| File | Purpose |
|---|---|
| `zfs/notes.md` | ZFS pool notes, property tuning, monitoring |

### 🖥️ Generic UNIX

| Path | Purpose |
|---|---|
| `generic-unix/prep-moods.sh` | Mood-based system config scripts |
| `generic-unix/etc/ssh/` | OpenSSH server configs (v9, v10, latest) |
| `generic-unix/etc/syslog-ng/` | Syslog-ng configuration templates |
| `generic-unix/home/me/` | User scripts — moods, readonly/readwrite toggles |
| `generic-unix/root/` | Root authorized_keys |

### 🎨 Images

| File | Description |
|---|---|
| `img/nix1.webp` | NixOS branding image |
| `img/nix2.webp` | NixOS branding image |

### ⚡ Helper Scripts

| File | Purpose |
|---|---|
| `nix/age-systemd-inject.nix` | Helper to inject age secrets into systemd services |
| `fastfetch/ff.jsonc` | Fastfetch (system info display) theme config |
| `opencode/opencode.jsonc` | OpenCode editor config |
| `todo/list.md` | Active task list & feature requests |

---

## 🔗 Cross-References

| Related | Link |
|---|---|
| Crush AI skills in repo | [doc/crush/](./crush/) |
| Generic skills installed | [../../.config/crush/skills/](../../.config/crush/skills/) |
| ZFS pool management | [../storage/ZFS.md](../storage/ZFS.md) |
| IoT devices | [../iot/README.md](../iot/README.md) |
| Main README | [../README.md](../README.md) |

---

*For the full system overview → [Main README](../README.md)*
