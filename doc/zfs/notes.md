<div align="center">

# 💿 ZFS notes

**Two small operational recipes: ARC sizing and 4K formatting a drive.**

</div>

---

## 🧠 ARC size

Set the ARC ceiling through a kernel parameter. The value is in bytes:

```nix
boot.kernelParams = [ "zfs.zfs_arc_max=51539607552" ]; # 48 GiB
```

Use this only when the pool and workload justify a fixed ceiling; the default
auto-sizing is correct for most machines.

## 🧰 Format a drive with 4K sectors

`openSeaChest` can low-level format a drive with 4096-byte sectors. This erases
the drive and can make it unusable if the interface or controller does not
support 4K logical sectors.

```bash
nix-shell -p openseachest

sudo openSeaChest_Format \
  -d /dev/sda \
  --formatUnit 4096 \
  --fastFormat 1 \
  --poll \
  --confirm this-will-erase-data-and-may-render-the-drive-inoperable
```

## ⚠️ Safety

- Verify the device path twice. `/dev/sda` is not a stable name.
- Prefer `/dev/disk/by-id/...` when the tool supports it.
- Never run a low-level format on a disk that holds data.

---

<p align="right"><sub><a href="../README.md">← doc</a> · <a href="../../storage/ZFS.md">ZFS</a></sub></p>
