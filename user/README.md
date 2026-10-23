<div align="center">

# 👤 User

**Home Manager for humans: shell, prompt, browsers, mail, desktop.**

[![Home Manager](https://img.shields.io/badge/Home%20Manager-declarative-5277C3)](https://github.com/nix-community/home-manager)
[![Shell](https://img.shields.io/badge/shell-zsh%20%2B%20starship-0891b2)](./resources/starship/gruvbox-rainbow.toml)
[![Desktop](https://img.shields.io/badge/desktop-GNOME%20%7C%20apps-0d9488)](../packages/desktop)

`./user/me.nix`

</div>

---

## 🗂️ What's in here

| File | Purpose |
|---|---|
| `me.nix` | Primary Home Manager entry point: shell, packages, desktop imports |
| `desktop/me.nix` | Desktop environment base |
| `desktop/me-firefox.nix` | Firefox policies, extensions, theme |
| `desktop/me-librewolf.nix` | Librewolf profile |
| `desktop/me-element.nix` | Element (Matrix) setup |
| `desktop/me-thunderbird.nix` | Thunderbird accounts and extensions |
| `resources/starship/gruvbox-rainbow.toml` | Starship prompt theme |
| `.attic/` | Retired Home Manager configs |

## 🚀 Structure

```nix
{ config, pkgs, lib, infra, ... }: {
  imports = [ ./desktop/me.nix ];

  home-manager.users.me = {
    home = {
      stateVersion = config.system.nixos.release;
      homeDirectory = "/home/me";
    };

    programs = {
      zsh.enable = true;
      starship.enable = true;
      git.enable = true;
      neovim.enable = true;
    };
  };
}
```

`home.stateVersion` follows `config.system.nixos.release`. It is a
compatibility pin, not a package version.

## 🎨 Prompt

The `gruvbox-rainbow.toml` theme adds time, user and host, git status,
language versions and a Gruvbox gradient. It is loaded through
`programs.starship.settings` or a copied config, depending on the host.

## 👥 Users

| User | Config | Role |
|---|---|---|
| `me` | `me.nix` | Primary desktop user |
| `mpaepcke` | [`person/mpaepcke.nix`](../person/README.md) | Full NixOS profile plus smartcard access |

## 📐 Rules

- Home Manager only. Do not enable system services here.
- Keep browser and mail profiles in `desktop/`, not in `me.nix`.
- No secrets. Use agenix and reference `config.age.secrets.<name>.path`.
- Format with `alejandra`.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../person/README.md">person</a> · <a href="../packages/README.md">packages</a></sub></p>
