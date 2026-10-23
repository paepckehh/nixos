<div align="center">

# 🛡️ Guard

**Zero-touch OpenWrt images for hardened Raspberry Pi 4 guard nodes.**

[![OpenWrt](https://img.shields.io/badge/OpenWrt-25.12-5277C3)](https://openwrt.org)
[![Hardware](https://img.shields.io/badge/hardware-Raspberry%20Pi%204-0891b2)](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/)
[![VPN](https://img.shields.io/badge/VPN-WireGuard-0d9488)](https://wireguard.com)

`ID=100 WPK='…' PSK='…' make config`

</div>

---

## 🗂️ What's in here

| Path | Purpose |
|---|---|
| `Makefile` | Image writing and config generation: `all`, `config`, `gen`, `sdcard` |
| `genall.sh` | Bulk restore-config generator |
| `secure.img.xz` | Base image deployed to SD cards |
| `openwrt-25.12.0-rc4-…-rpi-4-squashfs-factory.img.xz` | Pinned upstream factory image |
| `config.txt` / `config-wifi.txt` | Raspberry Pi boot config, Wi-Fi off / on |
| `distroconfig.txt` | Distro overlay |
| `manual.txt` | Operator notes |
| `etc/` | OpenWrt UCI config, dropbear keys, nftables, crontabs, profile scripts |
| `.attic/` | Archived backups, not for deployment |

## 🚀 Write an image

```bash
make sdcard                 # /dev/sda, with a 5 second cancel window
TARGET=sdb make sdcard      # specific block device
```

> This wipes the whole disk. There is a five second delay before `dd` starts.

## 🚀 Generate node configs

```bash
# One node
ID=100 WPK='<wireguard-private-key>' PSK='<pre-shared-key>' make config

# Bulk: nodes 100 through 109
ID=100 NEXT=10 WPK='<key>' PSK='<psk>' WIFI=0 make gen
```

Output lands in `TARGETDIR` (default `~/Downloads`) as
`RestoreME-<site>guard<id>-<timestamp>.tar.gz`.

## ⚙️ Targets and variables

| Target | Result |
|---|---|
| `make sdcard` | Write the base image |
| `make config` | One restore tarball |
| `make gen` | Bulk restore configs |
| `make all` | Show targets and variables |

| Variable | Default | Meaning |
|---|---|---|
| `TARGET` | `sda` | Block device |
| `ID` | — | Node IP suffix and hostname |
| `NEXT` | — | Number of bulk nodes |
| `WPK` | — | WireGuard private key |
| `PSK` | — | WireGuard pre-shared key |
| `NETWORK` | `10.20.66` | Node subnet |
| `BRAND` | `<site>guard` | Name embedded in configs |
| `WIFI` | `0` | `1` keeps Wi-Fi and LuCI enabled |
| `INSTANCE` | `turbo` | Instance profile |
| `TARGETDIR` | `~/Downloads` | Output directory |

## 🧱 Updating the base image

1. Open the [OpenWrt firmware selector](https://firmware-selector.openwrt.org/).
2. Select **Raspberry Pi 4B / 400 / CM4 (64-bit)**.
3. Enable **Customize installed packages** and add, without removing defaults:

```text
luci-ssl luci-mod-dashboard bind-dig vim-fuller fish whereis curl mtr btop \
kmod-lib-zstd kmod-wireguard luci-proto-wireguard wireguard-tools \
kmod-usb-net-asix kmod-usb-net-asix-ax88179 kmod-usb-net-cdc-ether \
kmod-usb-net-cdc-mbim kmod-mt7921-firmware kmod-mt7921u kmod-rtw88
```

4. Build, download **Factory Squashfs**, decompress and recompress:

```bash
gunzip image-name.img.gz
xz -9e image-name.img
ln -fs image-name.img.xz secure.img.xz
```

## 🔐 Security

- Root access uses passwordless SSH through dropbear with Ed25519 keys.
- nftables chains default to drop.
- Bluetooth and Wi-Fi are disabled by default (`config.txt`).
- Disk writes include a five second safety delay.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../openwrt/README.md">openwrt</a> · <a href="../iot/README.md">iot</a></sub></p>
