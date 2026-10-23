<div align="center">

# 🖥️ Hosts

**The last stacking layer: identity, network addresses, and host-specific switches.**

[![Targets](https://img.shields.io/badge/server%20hosts-2-5277C3)](../flake.nix)
[![Pattern](https://img.shields.io/badge/stack%20hardware%20→%20role%20→%20host-0891b2)](../README.md)

`TARGET=srv make switch`

</div>

---

## 🗂️ What's in here

| File | Purpose |
|---|---|
| `srv.nix` | Primary server identity: hostname, host ID, SSH listen address, Caddy and service switches. Receives `infra` via `specialArgs`. |
| `srv2.nix` | Secondary server identity. Imports `role/server.nix` and reads `infra` from the module args. |

Other targets (`kiosk`, `internet`, `client`, `iso`, `iso-installer`,
`srv-full`) are assembled directly in [`flake.nix`](../flake.nix) and have no
file in this directory.

## 🚀 How a host is assembled

A host file is not a full system. It is the final override layer on top of
hardware, storage, roles, packages and modules:

```nix
{ config, pkgs, lib, infra, ... }: {
  networking = {
    hostName = lib.mkForce infra.srv.name;
    hostId = lib.mkForce infra.srv.hostID;
    extraHosts = "${infra.srv.user.ip} ${infra.srv.hostname} ${infra.srv.user.fqdn}";
  };

  services = {
    caddy.enable = lib.mkForce infra.srv.reverseproxy;
    openssh = {
      enable = lib.mkForce infra.srv.sshd;
      listenAddresses = lib.mkForce [{
        addr = infra.srv.admin.ip;
        port = infra.port.ssh-mgmt;
      }];
    };
  };
}
```

Every value comes from [`siteconfig/config.nix`](../siteconfig/config.nix).
`lib.mkForce` is intentional: hosts must win over role defaults.

### Stack order

```text
configuration.nix  →  storage  →  hardware  →  role  →  host  →  services
```

`role/server.nix` sets the agenix identity path and the baseline hardening.
`hosts/srv.nix` is the only host that currently receives `infra` via
`specialArgs`; the other targets import it directly instead.

## 🔧 Build

```bash
TARGET=srv make boot       # build and install a boot entry
TARGET=srv make switch     # build and activate now
make rollback              # previous generation
```

## ⚠️ Known state

`srv2` and `srv-full` reference files that do not exist today
(`packages/devops-core.nix`, `storage/stateless-luks-partlabel.nix`). They fail
evaluation until those are added. Prefer fixing the target you were asked about
over mass-repairing the flake.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../role/README.md">role</a> · <a href="../siteconfig/README.md">siteconfig</a></sub></p>
