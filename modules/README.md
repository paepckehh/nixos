<div align="center">

# 🔐 Modules

**The trust store: 51 agenix secrets, one purpose each, no plaintext in git.**

[![Secrets](https://img.shields.io/badge/secrets-51%20sealed-7c3aed)](../modules/resources)
[![Agenix](https://img.shields.io/badge/encryption-agenix-0d9488)](https://github.com/ryantm/agenix)
[![Identity](https://img.shields.io/badge/identity-host%20ed25519-0891b2)](../role/server.nix)

`age.secrets.<name>.file = ../../modules/resources/<name>.age;`

</div>

---

## 🗂️ What's in here

`modules/resources/` is the only place secrets live. Everything is encrypted for
the persisted host key, so a stolen repo or a stolen laptop yields nothing.

| Type | Purpose |
|---|---|
| `*.age` | One encrypted secret per service or purpose (51 files) |
| `secrets.nix` | Shared helper wiring for the secret set |
| `genkey32.sh` | Generate 32-byte random material |
| `gencert.sh` | Generate a self-signed TLS keypair |
| `gencert-ecdsa.sh` | Generate an ECDSA TLS keypair |
| `maintainer.nix` | Query packages by maintainer |
| `restart-services-srv.sh` | Restart the service set after secret rotation |

Secret families currently in the store include Authelia (JWT, OIDC HMAC and
issuer, session, storage key), LLDAP (admin, JWT, key, seed), PKI/vaultls,
Maddy and Roundcube, Zammad (database and key), Nextcloud, Paperless, OnlyOffice
(JWT and nonce), Matrix, WireGuard (private and pre-shared keys), EcoFlow,
Tibber, openwrt admin, SMB, and Zitadel TLS.

## 🚀 Use a secret

```nix
age.secrets.vaultwarden.file = ../../modules/resources/vaultwarden.age;

services.vaultwarden.environmentFile = config.age.secrets.vaultwarden.path;
```

The decryption identity is the persisted host key, set in
[`role/server.nix`](../role/server.nix):

```nix
age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];
```

## 🔧 Mint key material

```bash
./modules/resources/genkey32.sh        # 32 random bytes
./modules/resources/gencert.sh         # self-signed TLS keypair
./modules/resources/gencert-ecdsa.sh   # ECDSA TLS keypair
```

These scripts generate material only. Encryption and recipient management are
still agenix operations; never commit the plaintext output.

## 📐 Rules

- Never edit, re-encrypt or replace a `.age` file by hand.
- Never add a plaintext secret, token or password to a module.
- One `.age` file per purpose, so rotation has a small blast radius.
- Test decryption on the target host, not in a shell with your personal key.
- Host keys live in `/nix/persist/etc/ssh`; rotate them and you must re-encrypt.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../role/README.md">role</a> · <a href="../server/README.md">server</a></sub></p>
