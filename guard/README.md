# 🛡️ Guard — Hardened OpenWRT Security Gateways

> ESP32 + OpenWRT security appliances for zero-trust remote access. Hardened networking, encrypted tunnels, and mesh topology — all declarative.

---

## 🔥 What Is Guard?

Guard is a **security gateway system** built on OpenWRT that turns consumer-grade hardware into fortress-like remote-access endpoints. Think of it as the physical/perimeter layer of your zero-trust architecture:

```
Internet (untrusted) ──> [Guard Node ───────────────────> Internal Network (trusted)
                         │  OpenWRT
                         │  ESP32 mesh
                         │  WireGuard overlay
                         │  Port knocking / time-based auth
                         ──────────────────────────]
```

### Supported Hardware

| Board | Target | Flash | RAM |
|---|---|---|---|
| **GL-AXT1800** | `axt` | 256 MB | 512 MB |
| **GL-B3000** | `b3000` | 256 MB | 1 GB |
| **D-Link DAP-X1860-A1** | `dap` | 128 MB | 256 MB |
| **Raspberry Pi** | `rpi2` | SD/USB | 1+ GB |

## 📂 What's In Here

| File | Purpose |
|---|---|
| `README.md` | This file — project overview |
| `Makefile` | Build system — compiles OpenWRT firmware images per-target |
| `config/` | OpenWRT network & wireless configs |
| `images/` | Built firmware images (`.bin` files) |

### WiFi & Network

| File | Purpose |
|---|---|
| WiFi setup scripts | SSID, channel, band, and auth configuration per-board |
| TFTP config | PXE/TFTP boot settings for headless provisioning |

## 🚀 Quick Start

### Build a Firmware Image

```bash
cd /etc/nixos/openwrt

# Build for GL-AXT1800 (2x2 AC1800 dual-band)
make axt

# Build for GL-B3000 (Wi-Fi 6)
make b3000

# Build for D-Link DAP-X1860-A1
make dap

# Build for Raspberry Pi 2
make rpi2
```

### Flash & Provision

```bash
# Via web UI (default: http://192.168.1.1, admin/admin)
# Or via SSH after initial setup
ssh root@<gateway-ip>
# Flash new firmware
mtd write /tmp/openwrt-<board>-sysupgrade.bin firmware
reboot
```

## 🔐 Security Features

- **WireGuard overlay** — encrypted tunnel between all guard nodes
- **OpenWRT hardened kernel** — firewall defaults, disabled telnet/SSH password auth
- **ESP32 mesh** — secondary communication layer via LoRa/mesh
- **Port knocking** — hidden SSH, only visible to clients who know the knock sequence
- **Isolated VLANs** — guest, IoT, and management networks separated

## 📊 Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  GL-AXT1800 │◄──>│  GL-B3000   │◄──>│  D-Link DAP │
│  (WiFi 5)   │    │  (WiFi 6)   │    │  (AP)        │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                   │                   │
       └───────────┬───────┴───────────────────┘
                   │
            ┌──────▼──────┐
            │  Internal    │
            │  Network    │
            └─────────────┘
```

---

*For the main router setup → [OpenWRT](../openwrt/README.md)*
*For full infrastructure overview → [Main README](../README.md)*
