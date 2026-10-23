<div align="center">

# ⚙️ Siteconfig

**One attrset for the whole company: IDs, IPs, domains, ports, users, hardening.**

[![Source of truth](https://img.shields.io/badge/source-of%20truth-5277C3)](./config.nix)
[![Values](https://img.shields.io/badge/one%20file-2.2k%20lines-0891b2)](./config.nix)
[![Consumers](https://img.shields.io/badge/every%20module-imports%20it-0d9488)](../server)

`let infra = (import ../../siteconfig/config.nix).infra; in`

</div>

---

## 🗂️ What's in here

| File | Purpose |
|---|---|
| `config.nix` | The live source of truth. Exports the `infra` attrset used everywhere. |
| `base.nix` | Base site values |
| `home.nix` | Home and personal infrastructure values |
| `paepcke.nix` | User-level settings |
| `example.nix` | Scaffold for a new site |
| `sample1.nix` … `sample3.nix` | Sample layouts for experiments |
| `smbgate-mounts.nix` | SMB gate mount points |
| `.attic/` | Retired site layouts |

## 🌍 The `infra` shape

`config.nix` is a plain Nix expression: `let infra = { … }; in { inherit infra; }`.
It is not a NixOS module and defines no options.

Top-level keys include:

| Key | Holds |
|---|---|
| `site` | Site id (`50`), name (`home`), domain (`corp`, `paepcke.de`), network range (`10.50.0.0/16`) |
| `locale` | Timezone, keymap, language, locale prefixes |
| `nix` | NixOS version and binary cache URLs and keys |
| `me` / `admin` / `backup` | Identity, UIDs |
| `storage` / `kernel` | Disk and kernel policy, supported filesystems |
| `localhost` | Loopback conventions (`port.offset`) |
| `vlan` / `net` / `cidr` | Network scopes: `net.user`, `net.admin`, … |
| `domain` / `zonename` / `namespace` | DNS zones and container namespaces |
| `port` | Well-known ports (`ssh-mgmt = 6623`, …) |
| `proxy` / `proxies` / `opn` / `modem` | Reverse proxy and edge devices |
| `ssh` / `firefox` / `thunderbird` / `smtp` / `autoconfig` / `webmail` | Client defaults |
| `dns` / `adguard` / `cache` / `pki` / `iam` / `sso` | Platform services |
| `srv` / `srv2` | Per-host identity, addresses, feature switches |
| `<service>` | One block per service, see below |

### Service block convention

```nix
crush = {
  id = 191;                     # last IPv4 octet and port offset
  app = "crush";
  name = infra.crush.app;
  hostname = infra.crush.name;
  domain = infra.domain.user;
  fqdn = "${infra.crush.hostname}.${infra.crush.domain}";
  ip = "${infra.net.user}.${toString infra.crush.id}";
  localbind.port.http = infra.localhost.port.offset + infra.crush.id;
  url = "https://${infra.crush.fqdn}";
  logo = "${infra.res.url}/icon/png/crush.png";
};
```

- `id` is both the last IPv4 octet and the loopback port offset (`7000 + id`).
- `net.user` is for user-facing services, `net.admin` for admin services.
- Pick an unused `id`. Duplicates already exist (`erpnext` and
  `networking-toolbox` are both `176`); do not add more.

## 🚀 Consume it

Direct import works on every host and is the safest choice:

```nix
{ config, pkgs, lib, ... }:
let
  infra = (import ../../siteconfig/config.nix).infra;
in {
  networking.hostName = infra.srv.name;
  services.openssh.listenAddresses = [{
    addr = infra.srv.admin.ip;
    port = infra.port.ssh-mgmt;
  }];
}
```

Some newer modules take `infra` as a function argument instead. That only works
on targets whose `specialArgs` pass it; today only `srv` does.

## 📐 Rules

- Never hardcode an IP, port, domain or UID outside this file.
- Adding a service means adding an `infra.<name>` block first.
- Do not rename existing keys without updating every consumer.
- Values here are data, not behaviour; keep modules declarative.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../hosts/README.md">hosts</a> · <a href="../server/README.md">server</a></sub></p>
