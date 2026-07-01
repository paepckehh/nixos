# Guard

[![OpenWrt](https://img.shields.io/badge/OpenWrt-23.05-brightgreen?style=flat-square)](https://openwrt.org/)
[![Raspberry Pi](https://img.shields.io/badge/Hardware-Raspberry%20Pi%204-blue?style=flat-square)](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/)
[![WireGuard](https://img.shields.io/badge/VPN-WireGuard-green?style=flat-square)](https://wireguard.com/)

A hardened, zero-touch OpenWrt base-image deployment toolkit for building secure wireless guard nodes on Raspberry Pi 4 devices. Provisions hardened WireGuard tunnel based client corporate access devices with minimal manual configuration.

## Features

- **Pre-configured OpenWrt base image** — zero-touch deployment via SD card
- **WireGuard VPN** — server and client support with auto-generated configs
- **Firewall (nftables)** — custom filter chains with drop/policy defaults
- **Bulk provisioning** — generate restore configs for multiple nodes at once

## Quick Start

### Prerequisites

- `make` (GNU Make)
- `curl`, `xz`, `gzip`, `tar`
- `sudo` or a user with passwordless root access
- A Raspberry Pi 4 (4/8 GB)
- SD card and card reader

### Write an Image to SD Card

```bash
# Write to /dev/sda (default)
make sdcard

# Write to a specific device
TARGET=sdb make sdcard
```

> ⚠️ This will **wipe the entire disk**. You have 5 seconds to cancel before `dd` begins.

### Generate a Node Config

```bash
ID=100 WPK='<wireguard-private-key>' PSK='<pre-shared-key>' make config
```

Output: `~/Downloads/RestoreME-<site>guard100-<timestamp>.tar.gz`

### Bulk Provisioning

```bash
ID=100 NEXT=10 WPK='<key>' PSK='<psk>' WIFI=0 make gen
```

Generates restore configs for nodes `100` through `109`. Set `WIFI=1` to keep Wi‑Fi and the LuCI web GUI enabled.

## Make Targets

| Target | Description |
| --- | --- |
| `make sdcard` | Write the base image to `/dev/sda` |
| `TARGET=sdb make sdcard` | Write to a specific block device |
| `make config` | Generate a single node restore tarball |
| `make gen` | Bulk-generate restore configs (requires `NEXT` or `ID`) |
| `make all` | Show all available targets and env vars |

## Environment Variables

| Variable | Default | Description |
| --- | --- | --- |
| `TARGET` | `sda` | Target block device (e.g. `sda`, `sdb`) |
| `ID` | — | Node IP suffix and hostname identifier (required) |
| `WPK` | — | WireGuard private key (required for `config`) |
| `PSK` | — | WireGuard pre-shared key (required for `config`) |
| `NETWORK` | `10.20.66` | Subnet for the node's primary network |
| `BRAND` | `<site>guard` | Brand/organization name embedded in configs |
| `WIFI` | `0` | Set to `1` to enable Wi‑Fi and LuCI GUI |
| `INSTANCE` | `turbo` | Instance profile identifier |
| `TARGETDIR` | `~/Downloads` | Output directory for generated configs |

## Updating the Base Image

To update the Raspberry Pi OpenWrt firmware for Wi‑Fi client deployments:

1. Visit [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org/)
2. Select **Raspberry Pi 4B / 400 / CM4 (64-bit)**
3. Choose the desired firmware version
4. Enable **Customize installed packages**
5. Add the following packages (do not remove defaults):

```
luci-ssl luci-mod-dashboard bind-dig vim-fuller fish whereis curl mtr btop \
kmod-lib-zstd kmod-wireguard luci-proto-wireguard wireguard-tools \
kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-cdc-ether \
kmod-usb-net-cdc-mbim kmod-mt7921-firmware kmod-mt7921u kmod-rtw88
```

6. Click **REQUEST BUILD** and wait for status: *Build Successful*
7. Download **Factory Squashfs**
8. Decompress and recompress:

```bash
gunzip image-name.img.gz
xz -9e image-name.img
```

9. Replace the image in the project:

```bash
ln -fs image-name.img.xz secure.img.xz
```

## Project Structure

```
guard/
├── Makefile              # Deployment & provisioning targets
├── genall.sh             # Bulk config generator script
├── secure.img.xz         # OpenWrt base image (deployed via IMGSRC)
├── config.txt            # Raspberry Pi config (Wi‑Fi disabled)
├── config-wifi.txt       # Raspberry Pi config (Wi‑Fi enabled)
├── distroconfig.txt      # Distro-specific overlay
├── etc/                  # OpenWrt uci configs & SSH keys
│   ├── config/           # network, firewall, wireless, etc.
│   ├── dropbear/         # SSH host keys
│   ├── nftables.d/       # netfilter rules
│   ├── profile.d/        # Shell init scripts
│   └── crontabs/         # Scheduled tasks
└── .attic/               # Archived backups (not for deployment)
```

## Security Notes

- Root access is via passwordless SSH (`dropbear`) with Ed25519 keys
- Firewall uses `nftables` drop chains as the default policy
- The base image disables Bluetooth and Wi‑Fi by default (`config.txt`)
- All disk writes include a 5-second safety delay before `dd` begins

## License

Internal
