# 📡 OpenWRT — Firmware Builder & Router Fleet

> Declarative OpenWRT firmware for a fleet of consumer routers — GL-Inet, D-Link, Raspberry Pi. Mesh VPN, monitoring, and automated provisioning.

---

## 🔥 What Is This?

A **firmware build system** for OpenWRT that compiles custom router images for different hardware targets. Each build includes:

- **WireGuard client** — connects to the HQ WireGuard overlay
- **Prometheus node exporter** — monitors router CPU/memory/network stats
- **Grafana agent** — ships metrics to the central Grafana instance
- **OpenWRT admin password** — stored as encrypted `.age` file
- **Custom wireless config** — SSID, channel, band, security per-board

## 📂 What's In Here

| File / Dir | Purpose |
|---|---|
| `README.md` | This file — firmware build guide |
| `Makefile` | Build system with per-target firmware compilation |
| `config/` | OpenWRT configuration files (network, wireless, packages) |
| `prometheus/` | Prometheus node_exporter + grafana-agent configs |
| `tftp/` | TFTP/PXE boot configuration for headless provisioning |

### Router Targets

| Target | Board | Specs |
|---|---|---|
| `dap` | **D-Link DAP-X1860-A1** | AC1900 dual-band, 3 ant, 128 MB flash |
| `axt` | **GL-AXT1800** (Bramble) | AC1800 WiFi 5, 256 MB flash, USB |
| `b3000` | **GL-B3000** (Mesa) | WiFi 6 AX3000, 256 MB flash, 2xGB RAM |
| `rpi2` | **Raspberry Pi 2/3/4** | ARM64, SD/USB boot, flexible deployments |

## 🚀 Building Firmware

### Build a Single Target

```bash
cd /etc/nixos/openwrt

# Build GL-AXT1800 firmware
make axt

# Build GL-B3000 firmware
make b3000

# Build D-Link DAP-X1860-A1 firmware
make dap
```

### Build All Targets

```bash
make all    # Builds every target at once
```

### Custom Configurations

```bash
# Build with custom OpenWRT admin password
make axt OPENWRT_ADMIN_PWD='<your-password>'

# Build with a specific kernel version
make b3000 KERNEL_VERSION='<branch>'
```

## 🔧 What Gets Included

Every firmware image includes:

| Component | Purpose |
|---|---|
| OpenWRT base | Latest OpenWRT snapshot for each board |
| WireGuard | Encrypted tunnel client for mesh VPN |
| Prometheus node_exporter | Hardware metrics (CPU, RAM, temp, net) |
| Grafana agent | Pushes metrics to central Grafana |
| LuCI admin | Web UI for router management |
| OpenWRT admin password | Pre-configured via encrypted config |

## 📊 Network Topology

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  GL-AXT1800  │         │  GL-B3000    │         │  D-Link DAP  │
│  Office GW   │         │  Branch-1    │         │  Branch-2    │
└──────┬───────┘         └──────┬───────┘         └──────┬───────┘
       │ WG mesh                 │ WG mesh                │ WG mesh
       │                         │                        │
       └───────────┬─────────────┴────────────────────────┘
                   │
          ┌────────▼────────┐
          │  HQ Router      │
          │  (Main LAN)     │
          └─────────────────┘
```

## 🔐 Credentials

The OpenWRT admin password is stored encrypted:

- **Location**: `modules/resources/openwrt-admin-pwd.age`
- **Key**: YubiKey via age-plugin
- **Build-time**: Injected by the Makefile during firmware compilation

> ⚠️ Never store plaintext passwords. Always use the `.age` encrypted variant.

## 📈 Monitoring

Each router reports metrics via Prometheus node_exporter:

| Metric | Label |
|---|---|
| `node_cpu_seconds_total` | CPU usage per core |
| `node_memory_*` | RAM & swap utilization |
| `node_temperature_*` | SoC temperature |
| `node_network_*` | RX/TX throughput, packet errors |
| `wireguard_peers_*` | WireGuard peer status & bytes |

All metrics flow to the central Grafana instance for dashboard visualization.

---

*For guard/security gateways → [Guard](../guard/README.md)*
*For Prometheus monitoring → [Server/Monitoring](../server/monitoring/)*
*For main infrastructure overview → [Main README](../README.md)*
