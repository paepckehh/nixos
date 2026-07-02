# 🎭 Role — Role-Based NixOS Profiles

> Two base roles: admin (full infrastructure control) and server (service-only, no GUI). The skeleton every host profile hangs on.

---

## 🗂️ What's In Here

Role-based module definitions that provide a **common baseline** for different kinds of machines in the infrastructure.

| File | Purpose |
|---|---|
| `adm.nix` | **Admin role** — full tooling, SSH keys, sudo config, monitoring access, dev packages |
| `server.nix` | **Server role** — bare-bones, no GUI, only service packages, hardened networking |

### Archived

| Directory | Contents |
|---|---|
| `.attic/` | Previous role definitions, retired configurations |

---

## 🚀 How Roles Work

Roles are **composable baselines** — they set defaults and capabilities but don't specify host identity. A complete config stacks a role on top of its host:

```nix
# In hosts/srv.nix
{ imports = [
    ../role/adm.nix      # ← Admin role (SSH keys, tooling, dev packages)
    ../role/server.nix   # ← Server role (services, networking)
  ];
}

# In hosts/srv2.nix  
{ imports = [
    ../role/adm.nix      # ← Also an admin machine
    ../role/server.nix   # ← With extra GNOME desktop packages
  ];
}
```

### Admin Role Includes

| Category | Contents |
|---|---|
| SSH | Host keys, authorized_keys, agent forwarding |
| Packages | All dev tools, editors, CLI tools, NixOS tooling |
| Sudo | Full sudoers config for infrastructure management |
| Monitoring | Prometheus, Grafana, dashboards |
| Shell | Zsh, starship prompt, aliases, tab-completion |

### Server Role Includes

| Category | Contents |
|---|---|
| Services | Base service daemon configs |
| Networking | Hardened network defaults, firewall baseline |
| Logging | Log forwarding, journald config |

---

## 🧬 Role Composition

Think of roles as **trait types** in a type system:
This makes it possible to **mix and match** different capability sets without duplicating configurations.

---

*For user configs → [Person](../person/)*
*For host configs → [Hosts](../hosts/)*
