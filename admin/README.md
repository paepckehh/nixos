# 🔑 Admin — Infrastructure Tooling

> The command center: Makefiles, key generation scripts, and the scripts that keep the infrastructure running.

---

## 🗂️ What's In Here

The **admin layer** — everything that operates *on* the NixOS infrastructure rather than describing it. These are the Makefiles and helper scripts that glue everything together.

| File | Purpose |
|---|---|
| `Makefile.Example` | Template Makefile for creating new service targets |
| `Makefile.Generic` | Generic Makefile with portable NixOS build targets |
| `Makefile.Site.Home` | Site-specific Makefile with custom aliases & shortcuts |
| `keygen.sh` | Ed25519 / curve25519 key pair generation (for SSH, WireGuard, TLS) |

## 🚀 Quick Start

Generate a fresh key pair:

```bash
./keygen.sh <output_dir>
```

Use a Makefile as your build entry point:

```bash
make -f Makefile.Site.Home switch
make -f Makefile.Generic build
```

## 📐 Pattern

Each Makefile follows the same convention:

```makefile
build:
	nix build .#<profile>

switch: build
	nixos-rebuild switch --flake .#<profile>
```

This keeps the tooling **portable** across machines — no hardcoded paths, no host-specific assumptions.

---

*For the main NixOS build workflow → [Root Makefile](../Makefile)*
*For flake-based builds → [flake.nix](../flake.nix)*
