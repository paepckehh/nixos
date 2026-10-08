# 🔐 Modules — Reusable NixOS Building Blocks

> Profiles, hardening, secrets, logging — the Lego bricks every service stacks on top of.

---

## 🗂️ What's In Here

This directory contains the **core NixOS module library** — reusable, composable configurations that serve as the foundation for all host and service definitions.

### Hardening Profiles

| File | Security Level | Purpose |
|---|---|---|
| `hardening.nix` | Standard | Baseline hardening — sysctl tuning, firewall rules, audit logging |
| `hardening-full.nix` | Enhanced | Full hardening + SELinux policies, kernel lockdown, AppArmor profiles |
| `hardening-max.nix` | Maximum | Maximum security — disable all non-essential features, kernel patches, strict network policies |

### Secrets & Encryption

| File | Purpose |
|---|---|
| `sops.nix` | SOPS/agenix setup — age encryption, key sources, keygen helpers |

### Logging

| File | Purpose |
|---|---|
| `log.nix` | Logging pipeline setup — journald forwarding, syslog-ng configuration, log aggregation |

### Resources

| Directory | Contents |
|---|---|
| `resources/` | 52+ encrypted `.age` secret files (one per service), certificate generation scripts, key management |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Legacy hardening profiles, retired key providers |

---

## 🔑 Secret Management

Secrets live in `resources/*.age` and are injected via **agenix**:

```nix
{
  imports = [ ./modules/sops.nix ];
  secrets = {
    bind-key = { sopsFile = ./modules/resources/bind.age; };
    nextcloud-admin = { sopsFile = ./modules/resources/nextcloud-admin.age; };
  };
}
```

**Key derivation** happens via:
- **YubiKey** via `age-plugin-yubikey` — your hardware key is your decryption key
- **Smartcard** (OpenSC/PKCS#11) — enterprise-grade key storage
- **SSH agent** — for CI/CD pipeline secrets

### Available Agent Files

| File | Purpose |
|---|---|
| `gencert-ecdsa.sh` |Generate ECDSA certificates |
| `gencert.sh` | Generate RSA/X.509 certificates |
| `genkey32.sh` | Generate Ed25519 keys |

---

## 🧱 Hardening Profile Comparison

| Feature | `hardening` | `hardening-full` | `hardening-max` |
|---|---|---|---|
| Sysctl tuning | ✅ | ✅ | ✅ |
| Audit logging | ✅ | ✅ | ✅ |
| SELinux | ❌ | ✅ | ✅ |
| AppArmor | ❌ | ✅ | ✅ |
| Kernel lockdown | ❌ | ❌ | ✅ |
| Network hardening | ✅ | ✅ | ✅ |
| Disable USB/Bluetooth | ❌ | ❌ | ✅ |

---

## 📐 Design Philosophy

- **Composable** — import whatever you need, mix & match
- **Non-destructive** — hardening is additive, never removes functionality
- **Testable** — each profile can be built independently
- **Progressive** — start with `hardening`, level up to `full`, then `max`

---

*For secrets in practice → [modules/resources/](./resources/)*
*For host configs that use these modules → [Hosts](../hosts/)*
