<div align="center">

# 🧠 Backlog

**Candidate services, tools and reading. Nothing here is enabled by default.**

[![Status](https://img.shields.io/badge/status-ideas%20only-f59e0b)](../README.md)
[![Promote](https://img.shields.io/badge/to%20ship-add%20a%20module-0d9488)](../../server/all)

</div>

---

## 🗂️ How to use this list

Each entry is a candidate. To turn one into a service:

1. Add an `infra.<name>` block in `siteconfig/config.nix`.
2. Create `server/all/<name>.nix` and symlink it into a category.
3. Add the import to the intended host, or leave it commented as a flag.
4. Move or remove the line here.

## 📄 Documents

| Item | Notes |
|---|---|
| `C4illin/ConvertX` — [web app doc converter](https://github.com/C4illin/ConvertX) | Convert between document formats |
| `fancy-cat` | PDF viewer |

## 🤖 AI

| Item | Notes |
|---|---|
| Perplexica — [ItzCrazyKns/Perplexica](https://github.com/ItzCrazyKns/Perplexica) | Search and answer engine |
| `TabbyML/tabby` — [repo](https://github.com/TabbyML/tabby) | Candidate `services.tabby` |
| `hybridgroup/go-haystack` | Apple Go Haystack |

## 🏠 Network and edge

| Item | Notes |
|---|---|
| UpSnap — [seriousm4x/UpSnap](https://github.com/seriousm4x/UpSnap) | Wake-on-LAN portal |
| `jokob/NetAlertX` | Network presence monitoring |
| `leiweibau/Pi.Alert` | Network scan and presence |
| [Monitoring OpenWrt traffic with syslog-ng](https://balagetech.com/monitor-network-traffic-openwrt-syslog-ng/) | Reference |
| [Lachee/opnsense-oidc](https://github.com/Lachee/opnsense-oidc) | OIDC for OPNsense |
| [IPFire WPAD](https://www.ipfire.org/docs/configuration/network/proxy/extend/wpad) | Proxy autodiscovery |
| `scanopy` | Network diagram generation |
| `jphoke/tlsscanner` | TLS scan web app |
| `tinylama/rsyslog-webui` | syslog web UI |

## 📊 Prometheus

| Item | Notes |
|---|---|
| `AthennaMind/opnsense-exporter` | OPNsense metrics |
| `hansmi/prometheus-paperless-exporter` | Paperless metrics |
| `jckuester/weather-station` | Weather metrics |

## ☎️ SIP and telephony

| Item | Notes |
|---|---|
| [Asterisk on NixOS](https://stuebinm.eu/posts/local-asterisk-nix-deployment.html) | Deployment write-up |
| [blog.griebsch.de](https://blog.griebsch.de/) | Reference |

## 🔐 IAM and PKI

| Item | Notes |
|---|---|
| `asalimonov/authelia-admin` | Authelia + LLDAP admin UI |
| [drduh/YubiKey-Guide](https://github.com/drduh/YubiKey-Guide) | Smartcard and PIV reference |
| [picokeys.com](https://picokeys.com) | Pico HSM hardware |
| [pkimetal/pkimetal](https://github.com/pkimetal/pkimetal) | PKI linting |

## 💰 Business and project

| Item | Notes |
|---|---|
| `wallos:docker` | Subscription tracker |
| `makeplane/plane` | Project management |
| `nocodb/nocodb` | No-code database |
| [LogicLabs-OU/OpenArchiver](https://github.com/LogicLabs-OU/OpenArchiver) | Mail archiving |

## 🌍 Geo and community

| Item | Notes |
|---|---|
| [OSM street key](https://wiki.openstreetmap.org/wiki/DE:Key:de:strassenschluessel) | Address data |
| [OSM Straßenschlüssel](https://wiki.openstreetmap.org/wiki/DE:Stra%C3%9Fenschl%C3%BCssel) | Address data |
| [nix-freifunk](https://github.com/nix-freifunk/nix-freifunk) | Freifunk on Nix |
| [dwd.api.bund.dev](https://dwd.api.bund.dev) | German weather API |

## 🐧 Nix and systems

| Item | Notes |
|---|---|
| [nix-community/nix-init](https://github.com/nix-community/nix-init) | Package generation |
| `services.firewalld` / `firewalld-gui` | Firewall |
| [maikel.dev](https://maikel.dev) | VMs, FreeBSD |
| `dm-verity` | Verified read-only storage |
| [blog.frankleonhardt.com](https://blog.frankleonhardt.com) | FreeBSD, Nix, networking |
| [Booting NixOS from RAM](https://artemis.sh/2023/03/07/nixos-early-boot-running-from-ram.html) | Stateless and ISO ideas |
| [monotux.tech](https://www.monotux.tech/) | Nix mix |
| [Passing secrets to DynamicUser services](https://bertptrs.nl/2021/09/05/securely-passing-secrets-to-dynamicuser-systemd-services.html) | agenix + systemd |
| [blog.hofstede.it](https://blog.hofstede.it/) | ZFS, FreeBSD, BGP |

## 💻 Hardware

| Item | Notes |
|---|---|
| [HP T640 thin client review](https://goughlui.com/2024/10/03/review-hp-t640-thin-client-r1505g-8gb-ram-64gb-emmc/) | Fanless x86 node |
| `nakato/nixos` | Reference config |

---

<p align="right"><sub><a href="../README.md">← doc</a> · <a href="../../server/README.md">server</a></sub></p>
