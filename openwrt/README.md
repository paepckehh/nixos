<div align="center">

# 📡 OpenWrt

**Declarative firmware for a router fleet: GL.iNet, D-Link, Raspberry Pi.**

[![Firmware](https://img.shields.io/badge/firmware-OpenWrt-5277C3)](https://openwrt.org)
[![Boards](https://img.shields.io/badge/boards-3-0891b2)](./Makefile)
[![VPN](https://img.shields.io/badge/mesh-WireGuard-0d9488)](../server/vpn)

`make axt`

</div>

---

## 🗂️ What's in here

| Path | Purpose |
|---|---|
| `Makefile` | Fleet build entry point: `axt`, `dap`, `rpi2`, `b3000`, images, updates, backups |
| `openwrt.nix` | Shared NixOS-side router config |
| `alias.nix` | Shell aliases for the router fleet |
| `prometheus-grafana.nix` | Metrics shipping for routers |
| `tftp.nix` | TFTP/PXE provisioning |
| `manual.txt` | Operator notes |
| `glinet/gl-axt1800/` | GL-AXT1800 board flake and Makefile |
| `dlink/dap-x1860-a1/` | D-Link DAP-X1860-A1 board flake and Makefile |
| `rpi/rpi2/` | Raspberry Pi 2/3/4 board flake and Makefile |
| `resources/` | Board inputs and shared assets |

`b3000` exists as a Makefile target but has no board directory yet.

## 🚀 Build

```bash
cd /etc/nixos/openwrt

make axt        # GL-AXT1800
make dap        # D-Link DAP-X1860-A1
make rpi2       # Raspberry Pi
make images     # all three boards
make update     # refresh board flakes
make clean      # clean build output
```

Per-board operations are also available:

```bash
make axt.luci       # LuCI web UI bundle
make axt.dns        # DNS setup
make axt.backup     # back up router config
make axt.update     # update packages
```

## 🔧 What ships in an image

| Component | Purpose |
|---|---|
| OpenWrt base | Board-specific firmware |
| WireGuard | Encrypted tunnel into the HQ mesh |
| `node_exporter` | CPU, memory, temperature, network metrics |
| Grafana agent | Ships metrics to the central instance |
| LuCI | Router web UI |
| Admin password | Pre-provisioned from an encrypted secret |
| Wireless config | SSID, channel, band and security per board |

## 📊 Monitoring

Routers report through Prometheus `node_exporter`:

| Metric | Meaning |
|---|---|
| `node_cpu_seconds_total` | CPU usage per core |
| `node_memory_*` | Memory and swap |
| `node_temperature_*` | SoC temperature |
| `node_network_*` | Throughput and errors |
| `wireguard_peers_*` | Peer status and bytes |

## 🔐 Credentials

The admin password is stored in
[`modules/resources/openwrt-admin-pwd.age`](../modules/resources) and injected at
build time. Never put a plaintext password in a board file.

## 📐 Rules

- One board, one directory, one flake.
- Per-board Makefiles stay runnable on their own.
- Never commit build output or `result`.
- Keep router config declarative; no manual LuCI drift.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../guard/README.md">guard</a> · <a href="../freifunk/README.md">freifunk</a></sub></p>
