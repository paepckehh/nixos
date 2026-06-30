# 👤 Person — Per-User NixOS Configurations

> Personalized desktop environments, user-level dotfiles, security keys, and per-person infrastructure access.

---

## 🗂️ What's In Here

User-specific NixOS and Home Manager configurations. Each person gets their own identity: dotfiles, desktop environment, shell config, browser prefs, SSH keys, and infrastructure access.

| File | Purpose |
|---|---|
| `mpaepcke.nix` | Full NixOS user profile for mpaepcke — shell, packages, desktop |

### Desktop Configs

| Directory | Contents |
|---|---|
| `desktop/mpaepcke.nix` | User-specific desktop overrides (window manager, themes, shortcuts) |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Legacy user configurations, old LUKS profiles |

### Smartcard Resources

| Directory | Contents |
|---|---|
| `resources/smartcard/mpaepcke/.ssh/` | Ed25519-sk SSH keys (YubiKey-backed, FIDO2/U2F) |
| `resources/smartcard/mpaepcke/.ssh/install.sh` | Script to install smartcard SSH keys to authorized_keys |

---

## 🔐 Smartcard Integration

The user's YubiKey generates SSH Ed25519-sk keys:

```bash
# Deploy smartcard keys for this user
bash resources/smartcard/mpaepcke/.ssh/install.sh
```

These keys appear as `sk-ssh-ed25519@openssh.com` type — you must have the physical YubiKey plugged in to authenticate.

---

## 🎨 Desktop Configuration

User desktop configs follow the Home Manager pattern:

```nix
{ config, pkgs, ... }:
let
  infra = (import ../siteconfig/config.nix).infra;
in {
  home.username = "mpaepcke";
  home.homeDirectory = "/home/mpaepcke";

  imports = [
    ./desktop/mpaepcke.nix
  ];

  # Package selection
  home.packages = with pkgs; [
    # ... dev tools, browsers, editors
  ];

  # Shell & dotfiles
  programs.zsh.enable = true;
  programs.git.enable = true;
}
```

---

## 👥 Known Users

| User | Notes |
|---|---|
| `mpaepcke` | Primary user — full desktop + admin infrastructure access |

---

*For desktop packages → [Packages/desktop](../packages/desktop/)*
*For Home Manager configs → [User](../user/)*
