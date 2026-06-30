# 📦 Shared — Common Assets & Utilities

> Branding, YARA rules, repo tooling, and shared bookmark collections — the infrastructure's shared library.

---

## 🗂️ What's In Here

Everything that's **reused across multiple host configs or service modules** but doesn't belong to any single service.

### Repo Scripts

| Directory | Contents |
|---|---|
| `repo/` | `repo.sh` — repository management scripts for mirroring, pushing, cleaning |

### Branding

| Directory | Contents |
|---|---|
| `brand/` | Profile images & assets for dashboards, login screens, service logos |

| File | Purpose |
|---|---|
| `brand/deb.jpg` | Desktop environment branding image |
| `brand/me.jpg` | Personal branding / avatar image |
| `brand/me.kra` | Krita asset (author profile / signature) |
| `brand/me.png` | Personal branding image (PNG) |

### YARA Rules

| Directory | Contents |
|---|---|
| `yara/` | Malware detection signatures for Wazuh, ClamAV, or similar scanners |

| File | Purpose |
|---|---|
| `yara/Akira_Ransomware_YARA.yar` | YARA rule for Akira ransomware family |
| `yara/win.akira_auto.yar` | Automated YARA rule for Akira ransomware indicators |

### Bookmarks

| File | Purpose |
|---|---|
| `bookmarks.json` | Shared bookmark collection for the team/infra — useful URLs, dashboards, documentation |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Old branding assets, retired scripts |

---

## 🎨 Branding Assets

Brand images are used by:
- **Nextcloud** — instance branding, login page image
- **Grafana** — dashboard headers
- **Homer/Glance** — portal page header
- **Roundcube** — webmail branding

Import in any service that supports branding:

```nix
{
  services.nextcloud.extraConfigs.branding.logoPath = ./shared/brand/me.png;
}
```

---

## 🔍 YARA Rules

YARA rules live here because they're **shared across security services**:
- Wazuh uses them for endpoint detection
- ClamAV can import them for antivirus scanning
- ZIO can use them in intrusion detection pipelines

```yaml
# Example: Wazuh custom rules import
services.wazuh.manager.customRules = [
  ./shared/yara/Akira_Ransomware_YARA.yar
  ./shared/yara/win.akira_auto.yar
];
```

---

*For security services → [Server/soc](../server/soc/)*
*For service branding → [Server/portal](../server/portal/)*
