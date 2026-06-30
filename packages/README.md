# 📦 Packages — Nix Package Collections

> Every package set in one place: AI tools, devops, desktop apps, wine runners — organized by use case.

---

## 🗂️ What's In Here

The **package definition layer** — flake packages that define what software is available to each profile. Organized by category so you can pick and choose what to enable.

### Core Package Sets

| File | Purpose |
|---|---|
| `base.nix` | Essential packages — core utilities, CLI tools, shell, text editors |
| `devops.nix` | Devops toolkit: Go, Docker, NixOS tooling, security scanners |
| `devops-go.nix` | Go development environment (toolchain, linters, IDE tooling) |
| `devops-python.nix` | Python ecosystem (venv tools, data science, web frameworks) |
| `devops-nixos.nix` | NixOS-specific tooling (nixpkgs tools, nix-review, cachix) |
| `devops-docker.nix` | Docker ecosystem (compose, buildx, registry tools) |
| `devops-sec.nix` | Security tools (nmap, wireshark, Burp, scanners) |
| `devops-db.nix` | Database tools (CLI clients, migration tools, ORM wrappers) |
| `devops-office.nix` | Office automation (PDF tools, document converters) |
| `devops-html.nix` | HTML/CSS/JS toolchain (bundler, linters, formatters) |
| `devops-iot.nix` | IoT development (esptool, platformio, MQTT clients) |
| `devops-lora.nix` | LoRa development stack (meshtastic, semtech SDK) |
| `devops-net.nix` | Networking tools (tcpdump, scapy, speedtest) |
| `devops-ldap.nix` | LDAP tooling (OpenLDAP clients, admin tools) |
| `devops-lora.nix` | LoRa/Meshtastic development tools |
| `devops-guidev.nix` | Guide/Documentation tooling |
| `devops-ventoy.nix` | Ventoy bootable USB creation tools |
| `devops-wine.nix` | Wine & Windows app compatibility layer |
| `tmux.nix` | Tmux configuration + plugins |

### Desktop Packages

| Directory | Contents |
|---|---|
| `desktop/` | Desktop environment packages, applications, and extensions |

#### Desktop Subpackages

| File | Purpose |
|---|---|
| `desktop/gnome.nix` | GNOME desktop environment + extensions |
| `desktop/hyprland.nix` | Hyprland (hyrpy compositor) setup |
| `desktop/kde.nix` | KDE Plasma desktop environment |
| `desktop/cosmic.nix` | COSMIC desktop (Elementary OS desktop) |
| `desktop/kiosk.nix` | Kiosk mode — single-app, locked-down desktop |
| `desktop/browser.nix` | Web browsers (Firefox, Librewolf, Chrome) |
| `desktop/ai.nix` | AI tools for desktop (local LLM GUIs, inference) |
| `desktop/shared.nix` | Common desktop packages (file managers, file pickers) |
| `desktop/add-av.nix` | AV/antivirus desktop apps |
| `desktop/add-chrome.nix` | Google Chrome browser |
| `desktop/add-mindmap.nix` | Mind mapping tools (FreePlane, XMind) |
| `desktop/add-onlyoffice.nix` | OnlyOffice suite for desktop use |
| `desktop/add-rdp.nix` | RDP client (remmina, FreeRDP, xfreerdp) |
| `desktop/add-rss.nix` | RSS readers (Miniflux, FreshRSS desktop apps) |
| `desktop/add-sound.nix` | Audio tools (Audacity, LMMS, fluidsynth) |
| `desktop/add-vikunja.nix` | Vikunja task manager desktop client |
| `desktop/artist.nix` | Art creation tools (Krita, GIMP, Blender) |
| `desktop/dss-portal.nix` | DSS Portal application |
| `desktop/firejail-librewolf.nix` | Sandboxed Librewolf via Firejail |

#### Desktop Resources

| Directory | Contents |
|---|---|
| `desktop/resources/` | Desktop files (`.desktop`), JNLP webstart configs, icons |

#### Archived

| Directory | Contents |
|---|---|
| `desktop/.attic/` | Old desktop package configs, retired app profiles |
| `.attic/` | Legacy package definitions |

---

## 🚀 How Packages Work

Each `.nix` file exports a Nix package set via `pkgs`:

```nix
# In flake.nix or a host config
{
  environment.systemPackages = with pkgs; [
    (import ./packages/base.nix).myPackages
    (import ./packages/devops.nix).goTools
    (import ./packages/desktop/gnome.nix).gnomePackages
  ];
}
```

## 📊 Quick Reference

| Category | File | # of packages |
|---|---|---|
| Core | `base.nix` | ~50 essentials |
| Devops general | `devops.nix` | ~100+ tools |
| Go | `devops-go.nix` | Golang toolchain |
| Python | `devops-python.nix` | Python + data science stack |
| Nix | `devops-nixos.nix` | NixOS tooling |
| Desktop | `desktop/*.nix` | ~40+ apps |
| Security | `devops-sec.nix` | Sec tools + scanners |

---

*For user desktop configs → [User/desktop](../user/desktop/)*
*For dev services → [Server/devops](../server/devops/)*
