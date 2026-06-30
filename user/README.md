# 👤 User — Home Manager Configurations

> Per-user desktop environments, apps, shells, browsers, and dotfiles via Home Manager.

---

## 🗂️ What's In Here

Home Manager configurations for **individual user accounts**. Everything from shell prompt to browser extensions — declared declaratively in Nix.

| File | Purpose |
|---|---|
| `me.nix` | Full Home Manager config for the primary user — shell, IDE, browser, desktop, packages |

### Desktop Configs

| Directory | Contents |
|---|---|
| `desktop/me.nix` | Base desktop environment configuration |
| `desktop/me-element.nix` | Element (Matrix client) setup |
| `desktop/me-firefox.nix` | Firefox profile — extensions, policies, themes |
| `desktop/me-librewolf.nix` | Librewolf (privacy-focused Firefox fork) profile |
| `desktop/me-thunderbird.nix` | Thunderbird email client — accounts, extensions, templates |

### Resources

| Directory | Contents |
|---|---|
| `resources/starship/` | Starship prompt theme configs |
| `resources/starship/gruvbox-rainbow.toml` | Starship theme — colorful rainbow gruvbox aesthetic |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Old Home Manager configs, retired desktop profiles |

---

## 🚀 User Config Structure

Each user config follows the Home Manager pattern:

```nix
{ config, pkgs, lib, ... }:
let
  infra = (import ../siteconfig/config.nix).infra;
in {
  imports = [
    ./desktop/me.nix
    ./desktop/me-firefox.nix
  ];

  home = {
    username = "me";
    homeDirectory = "/home/me";
    stateVersion = "26.11";
  };

  programs = {
    zsh.enable = true;
    starship.enable = true;
    git.enable = true;
    neovim.enable = true;
  };

  home.packages = with pkgs; [
    # Dev tools
    # Browsers
    # Editors
    # Media
  ];
}
```

---

## 🎨 Browser Profile

Multiple browser profiles allow testing different configurations:

| Browser | File | Purpose |
|---|---|---|
| Firefox | `desktop/me-firefox.nix` | Main browsing with policies + extensions |
| Librewolf | `desktop/me-librewolf.nix` | Privacy-focused browsing |
| Element | `desktop/me-element.nix` | Matrix communication client |
| Thunderbird | `desktop/me-thunderbird.nix` | Email — accounts, extensions, templates |

---

## 🖌️ Starship Prompt

The `gruvbox-rainbow.toml` theme gives the shell a colorful, vibrant prompt with:

- Time, user, hostname indicator
- Git branch + status overlay
- Python/Go/Rust version indicators
- Custom gradient colors from the Gruvbox palette

```toml
# resources/starship/gruvbox-rainbow.toml
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"
```

---

## 👥 Known Users

| User | Config | Role |
|---|---|---|
| `me` | `me.nix` | Primary user |

---

*For the Home Manager version → [main README](../README.md)*
*For desktop packages → [Packages/desktop](../packages/desktop/)*
