<div align="center">

# 📦 Packages

**Package sets by use case: base, devops, desktop, AI, security, wine.**

[![Sets](https://img.shields.io/badge/sets-20%2B-5277C3)](../packages)
[![Desktop](https://img.shields.io/badge/desktop-19%20modules-0891b2)](../packages/desktop)
[![Nix](https://img.shields.io/badge/plain%20Nix-modules-0d9488)](https://nixos.org)

`./packages/base.nix`

</div>

---

## 🗂️ What's in here

Package sets are **plain NixOS modules**, not option-bearing modules. Import the
set you want into a host or profile.

### Base and devops

| File | Purpose |
|---|---|
| `base.nix` | Core utilities, CLI tools, shell, editors |
| `devops.nix` | The general devops toolkit |
| `devops-go.nix` | Go toolchain, linters, tooling |
| `devops-python.nix` | Python, venv tools, data science |
| `devops-nixos.nix` | NixOS and nixpkgs tooling |
| `devops-docker.nix` | Docker, compose, buildx |
| `devops-db.nix` | Database clients and migration tools |
| `devops-sec.nix` | Security scanners and network analysis |
| `devops-net.nix` | tcpdump, scapy, speedtest |
| `devops-ldap.nix` | LDAP clients and admin tools |
| `devops-iot.nix` | esptool, platformio, MQTT |
| `devops-lora.nix` | LoRa and Meshtastic tooling |
| `devops-fido2.nix` | FIDO2 and security-key tooling |
| `devops-nfc.nix` | NFC tooling |
| `devops-html.nix` | HTML/CSS/JS toolchain |
| `devops-office.nix` | PDF and document conversion |
| `devops-guidev.nix` | Documentation and guide tooling |
| `devops-ventoy.nix` | Ventoy USB creation |
| `devops-wine.nix` | Wine and Windows compatibility |
| `add-smb.nix` | SMB client packages |
| `ai.nix` | AI and local inference tooling |
| `tmux.nix` | tmux configuration and plugins |

### Desktop (`packages/desktop/`)

| File | Purpose |
|---|---|
| `gnome.nix` | GNOME environment and extensions |
| `kde.nix` | KDE Plasma |
| `hyprland.nix` | Hyprland compositor |
| `cosmic.nix` | COSMIC desktop |
| `kiosk.nix` | Single-app locked-down desktop |
| `browser.nix` | Firefox, Librewolf, Chrome |
| `ai.nix` | Local LLM GUIs and inference |
| `shared.nix` | Common desktop packages |
| `add-av.nix` | AV and antivirus apps |
| `add-chrome.nix` | Google Chrome |
| `add-mindmap.nix` | Mind mapping tools |
| `add-onlyoffice.nix` | OnlyOffice suite |
| `add-rss.nix` | RSS readers |
| `add-vikunja.nix` | Vikunja client |
| `artist.nix` | Krita, GIMP, Blender |
| `dss-portal.nix` | DSS portal |
| `firejail-librewolf.nix` | Sandboxed Librewolf |
| `hid.nix` | HID and input devices |
| `resources/` | `.desktop` files, JNLP configs, icons |
| `.attic/` | Retired desktop sets |

## 🚀 Use a set

```nix
imports = [
  ./packages/base.nix
  ./packages/devops.nix
  ./packages/desktop/gnome.nix
];
```

## ⚠️ Known state

The flake references `packages/devops-core.nix` (for `srv2`) and
`packages/devops-all.nix` (for `srv-full`). Neither file exists today. Add the
intended set or adjust the host import before relying on those targets.

## 📐 Rules

- One use case per file.
- No options, no host identity: just packages and program config.
- Do not add a formatter or linter here; `alejandra` is the only formatter.
- Format with `alejandra`.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../user/README.md">user</a> · <a href="../person/README.md">person</a></sub></p>
