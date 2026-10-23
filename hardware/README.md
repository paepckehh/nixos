<div align="center">

# 🔌 Hardware

**CPU, GPU and device profiles. One import per machine family.**

[![CPU](https://img.shields.io/badge/CPU-amd%20%7C%20intel-5277C3)](../hardware)
[![GPU](https://img.shields.io/badge/GPU-amd%20%7C%20intel-0891b2)](../hardware/all-gpu.nix)
[![Format](https://img.shields.io/badge/formatter-alejandra-0d9488)](../Makefile)

`imports = [ ./hardware/all.nix ./hardware/amd-gpu.nix ];`

</div>

---

## 🗂️ What's in here

| File | Purpose |
|---|---|
| `all.nix` | Universal hardware defaults: CPU, firmware and kernel basics for every x86_64 host |
| `all-gpu.nix` | Catch-all GPU module for mixed or hardware-agnostic builds |
| `amd.nix` | AMD CPU settings (microcode, power scheduling) |
| `amd-gpu.nix` | AMD Radeon graphics |
| `intel.nix` | Intel CPU settings (microcode, power management) |
| `intel-gpu.nix` | Intel Iris / UHD integrated graphics |
| `apple/intel/default.nix` | Intel MacBook profile: ACPI, trackpad, power management |
| `.attic/` | Retired device and GPU profiles |

There are no HP or Lenovo profiles in this tree today. Device support is limited
to the files above; add a new module beside them if you bring in new hardware.

## 🚀 Use a profile

```nix
{
  imports = [
    ./hardware/all.nix
    ./hardware/amd.nix
    ./hardware/amd-gpu.nix
    ./hardware/apple/intel/default.nix
  ];
}
```

Most modules guard their settings with `lib.mkIf`, so importing a profile on the
wrong machine is usually harmless. Kernel and microcode choices still come from
the CPU module (`amd.nix` or `intel.nix`).

## 📐 Rules

- One device family per file.
- Guard with `lib.mkIf` when a setting only makes sense on matching hardware.
- Do not hardcode host names or sites here.
- Format with `alejandra`.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../hosts/README.md">hosts</a> · <a href="../storage/README.md">storage</a></sub></p>
