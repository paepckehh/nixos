<div align="center">

# 📡 ESP32 flashing — Heltec V3

**Flash Meshtastic firmware to an ESP32-S3 board from a NixOS host.**

[![Board](https://img.shields.io/badge/board-Heltec%20V3%20(ESP32--S3)-5277C3)](https://meshtastic.org)
[![Tool](https://img.shields.io/badge/tool-esptool-0891b2)](https://github.com/espressif/esptool)
[![Firmware](https://img.shields.io/badge/firmware-Meshtastic-0d9488)](https://github.com/meshtastic/firmware/releases)

</div>

---

## 📋 Prerequisites

- Heltec V3 board (ESP32-S3) and a data-capable USB cable
- `pipx` available (for a one-off `esptool` install)
- Meshtastic factory firmware matching the board
- Root shell: the board appears as a serial device and the install script uses
  elevated permissions

## 🚀 Flash

```bash
# 1. Root shell and tooling
sudo bash
nix-shell -p pipx
pipx install esptool
export PATH=$PATH:/root/.local/bin

# 2. Download the firmware release for heltecv3 (esp32s3)
#    from https://github.com/meshtastic/firmware/releases
unzip firmware.zip

# 3. Flash the factory image
sh ./device-install.sh -f firmware-heltec-v3-x.xx.xx.xxxx.factory.bin
```

## 🧹 Clean up

On a stateless host, `pipx` and the firmware cache live in the ephemeral root.
Either reboot or remove the leftovers explicitly:

```bash
rm -rf /root/.cache /root/.local
```

## ⚠️ Notes

- Use the **factory** image, not the update image, for a blank or erased board.
- The board name in the release is `heltec-v3`; the SoC is `esp32s3`.
- If the serial port is not detected, check the cable and permissions before
  retrying; do not guess a device path.
- This guide is a runbook, not a Nix module. Flashing is a manual operation.

---

<p align="right"><sub><a href="../README.md">← doc</a> · <a href="../../iot/README.md">iot</a></sub></p>
