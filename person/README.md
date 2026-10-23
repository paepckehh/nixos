<div align="center">

# 👤 Person

**Per-person NixOS identity: Home Manager, shell, smartcard SSH keys.**

[![Users](https://img.shields.io/badge/people-mpaepcke-5277C3)](./mpaepcke.nix)
[![Smartcard](https://img.shields.io/badge/SSH-ed25519--sk-7c3aed)](./resources/smartcard/mpaepcke/.ssh)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-me.nix-0d9488)](../user/me.nix)

`imports = [ ../person/mpaepcke.nix ];`

</div>

---

## 🗂️ What's in here

| Path | Purpose |
|---|---|
| `mpaepcke.nix` | Full NixOS person profile: imports `user/me.nix`, sets the user description, SSH authorized keys and Home Manager shell aliases |
| `desktop/mpaepcke.nix` | Desktop layer: imports the person profile and `user/desktop/me.nix` |
| `resources/smartcard/mpaepcke/.ssh/id_ed25519_sk` | YubiKey-backed SSH key (FIDO2/U2F) |
| `resources/smartcard/mpaepcke/.ssh/id_ed25519_sk.pub` | Matching public key |
| `resources/smartcard/mpaepcke/.ssh/install.sh` | Install key material into the user's home |
| `.attic/` | Retired person configs |

The NixOS account is `me`; the directory is named after the person. Keep that
distinction: `users.users.me` in Nix, `person/mpaepcke/` on disk.

## 🔐 Smartcard keys

The key is `sk-ssh-ed25519@openssh.com`. Authentication requires the physical
YubiKey to be present and touched.

```bash
sudo bash person/resources/smartcard/mpaepcke/.ssh/install.sh
```

The script copies the key pair to `/home/me/.ssh`, fixes ownership and sets
`600`/`644` permissions. It does not add the key to `authorized_keys`; that is
driven declaratively by `infra.users.mp.openssh.authorizedKeys.keys`.

## 🚀 Use the profile

```nix
# hosts/srv.nix or a host module list
./person/desktop/mpaepcke.nix
```

The person profile provides identity and user-level config. It does not decide
which services run; that belongs to the host and the service modules.

## 📐 Rules

- Never commit a private key. The smartcard key is generated on the YubiKey.
- Keep `install.sh` idempotent and non-destructive.
- Authorized keys come from `siteconfig/config.nix`, not from this directory.
- Format with `alejandra`.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../user/README.md">user</a> · <a href="../role/README.md">role</a></sub></p>
