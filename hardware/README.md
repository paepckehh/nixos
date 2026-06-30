# 🔌 Hardware — Device-Specific NixOS Profiles

> From MacBooks to ThinkPads, HP towers to Intel mini-PCs — every machine gets its own NixOS config.

---

## 🗂️ What's In Here

Hardware abstraction layer. Each module configures the right kernel modules, firmware, GPU drivers, and power settings for a specific device or family.

### By Manufacturer

| Directory | Devices |
|---|---|
| `apple/` | MacBook (Intel-based) profiles with proper ACPI, trackpad, and power management |
| `hp/` | HP servers & workstations — Dell OptiPlex T640 and related hardware |
| `lenovo/` | ThinkPad family — X1 Carbon Gen7, T490, and more |

### By GPU

| File | GPU Vendor |
|---|---|
| `amd-gpu.nix` | AMD Radeon (open-source drivers) |
| `intel-gpu.nix` | Intel Iris / UHD integrated graphics |
| `all-gpu.nix` | Catch-all: enables all GPU drivers (for mixed/hardware-agnostic builds) |

### Core Defaults

| File | Purpose |
|---|---|
| `all.nix` | Universal hardware module — CPU/firmware defaults for all x86_64 hosts |
| `amd.nix` | AMD CPU-level config (power scheduling, microcode) |
| `intel.nix` | Intel CPU-level config (Turbo boost, power management, microcode) |

### Resources

| Directory | Contents |
|---|---|
| `resources/bios/` | UEFI BIOS configuration exports (JSON) for ThinkPad & HP devices |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Legacy hardware configs, deprecated GPU modules, old BIOS profiles |

---

## 🚀 How It Works

Hardware modules auto-detect your CPU/GPU via NixOS's `lib.mkIf` guards:

```nix
{
  imports = [
    ./hardware/all.nix
    ./hardware/amd-gpu.nix
    ./hardware/hp/t640/all.nix
  ];
}
```

The system automatically picks the right microcode, kernel params, and device drivers.

---

*For full system config → [Hosts](../hosts/) → [Main README](../README.md)*
