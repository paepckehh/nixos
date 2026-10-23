<div align="center">

# 📦 Shared

**Cross-cutting assets: branding, YARA rules, bookmarks and repo helpers.**

[![Brand](https://img.shields.io/badge/brand-images%20%2B%20Krita-5277C3)](../shared/brand)
[![YARA](https://img.shields.io/badge/YARA-Akira%20rules-7c3aed)](../shared/yara)
[![Bookmarks](https://img.shields.io/badge/bookmarks-team%20URLs-0891b2)](../shared/bookmarks.json)

`../shared/brand/me.png`

</div>

---

## 🗂️ What's in here

| Path | Contents |
|---|---|
| `brand/` | Brand images and editable assets: `deb.jpg`, `me.jpg`, `me.kra`, `me.png` |
| `yara/` | Detection rules: `Akira_Ransomware_YARA.yar`, `win.akira_auto.yar` |
| `bookmarks.json` | Shared bookmark collection: dashboards, docs, useful URLs |
| `repo/repo.sh` | Repository helper script with host-specific hardcoded paths |
| `.attic/` | Retired assets and scripts |

`repo/repo.sh` is a one-off helper from another host. Read it before running; it
is not a supported entry point.

## 🎨 Branding

Brand images are consumed by dashboards and web apps:

- Nextcloud login and instance branding
- Grafana dashboard headers
- Homer / Glance portal headers
- Roundcube webmail

```nix
{
  services.nextcloud.extraConfigs.branding.logoPath = ./shared/brand/me.png;
}
```

## 🔍 YARA rules

Shared because several security services consume them:

| Consumer | Use |
|---|---|
| Wazuh | Endpoint detection |
| ClamAV | Antivirus scanning |
| Other IDS pipelines | Indicator matching |

```nix
services.wazuh.manager.customRules = [
  ./shared/yara/Akira_Ransomware_YARA.yar
  ./shared/yara/win.akira_auto.yar
];
```

Rules are detection content, not exploit code. Keep attribution and update
rules from a trusted source.

## 📐 Rules

- Do not put secrets in this directory.
- Keep brand assets small; use web formats for anything served.
- Treat `repo/repo.sh` as read-only reference.
- Do not add a formatter; `alejandra` covers Nix only.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../server/README.md">server</a> · <a href="../doc/README.md">doc</a></sub></p>
