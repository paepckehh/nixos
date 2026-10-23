<div align="center">

# 🎭 Role

**Three composable baselines: admin, server, docker. Capabilities without host identity.**

[![Role](https://img.shields.io/badge/roles-3-5277C3)](../role)
[![Pattern](https://img.shields.io/badge/compose-not%20inherit-0891b2)](../README.md)

`imports = [ ../role/adm.nix ../role/server.nix ];`

</div>

---

## 🗂️ What's in here

| File | Purpose |
|---|---|
| `adm.nix` | Admin baseline: tooling, SSH keys, sudo, shell, diagnostics |
| `server.nix` | Server baseline: no GUI, service packages, hardened networking, agenix identity |
| `docker.nix` | Container runtime baseline |
| `.attic/` | Retired role definitions |

## 🚀 How roles compose

Roles set defaults and capabilities. They do not know the host name, the IP, or
which services are enabled. A host stacks them and overrides with
`lib.mkForce` where needed.

```nix
# hosts/srv.nix
imports = [
  ../role/adm.nix       # operator tooling and access
  ../role/server.nix    # hardened server base
  ../role/docker.nix    # only where containers are used
];
```

You can import more than one role. Later definitions win only where the module
uses plain assignments; `mkDefault`/`mkForce` precedence is deliberate and must
be preserved when refactoring.

## 🔐 Server role specifics

`role/server.nix` is the anchor for secrets on servers:

```nix
age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];
```

Secrets are bound to the persisted host key, not to a user's YubiKey at runtime.
If you rotate host keys, re-encrypt the secrets.

## 📐 Rules

- Roles never hardcode site values. Read them from `infra`.
- Do not turn a role into a host. Identity belongs in `hosts/`.
- Preserve `mkForce`/`mkDefault` precedence.
- Format with `alejandra`.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../hosts/README.md">hosts</a> · <a href="../person/README.md">person</a></sub></p>
