<div align="center">

# 🏠 IoT

**Power stations, energy meters, smart-home hubs and audio players, declared in Nix.**

[![Devices](https://img.shields.io/badge/integrations-5-5277C3)](../iot)
[![Hub](https://img.shields.io/badge/hub-Home%20Assistant-0891b2)](./homeassistant.nix)
[![Secrets](https://img.shields.io/badge/API%20keys-agenix-7c3aed)](../modules/resources)

`./iot/homeassistant.nix`

</div>

---

## 🗂️ What's in here

| File | Device | Purpose |
|---|---|---|
| `homeassistant.nix` | Home Assistant | Smart-home hub and automations |
| `ecoflow-mqtt.nix` | EcoFlow power station | MQTT telemetry: battery, solar input, status |
| `ecoflow-rest.nix` | EcoFlow power station | REST integration: notifications, access keys, devices |
| `tibber.nix` | Tibber | Real-time prices and consumption |
| `dab.nix` | DAB receiver | DAB/DAB+ radio streaming and control |
| `moode/` | Moode Audio | Player image, stream aliases, manual notes |

`moode/` is a subproject with its own Makefile and `alias.nix`; it is not a
regular NixOS module.

## 🚀 Integration pattern

IoT modules follow the same shape as server modules: import `infra`, enable the
service, and reference agenix secrets by path.

```nix
{ config, pkgs, lib, ... }:
let
  infra = (import ../siteconfig/config.nix).infra;
in {
  services.home-assistant = {
    enable = true;
    config = { /* ... */ };
  };

  age.secrets.tibber.file = ../modules/resources/tibber.age;
}
```

## 🔐 Secrets

| File | Purpose |
|---|---|
| `ecoflow-email.age` | EcoFlow account email |
| `ecoflow-password.age` | EcoFlow account password |
| `ecoflow-access-key.age` | API access key |
| `ecoflow-secret-key.age` | API secret key |
| `ecoflow-devices.age` | Device registry |
| `tibber.age` | Tibber API token |

Never inline a token in a module. Reference the decrypted path instead.

## 📊 Data flow

```text
EcoFlow  ──MQTT/REST──►  Home Assistant  ◄──Tibber
                              │
                              ▼
                     Prometheus + Grafana
```

Devices publish into the hub; the hub and Prometheus expose the resulting state
and metrics.

## 📐 Rules

- One device family per file.
- Read site values from `infra`, never hardcode an address.
- Secrets only through agenix.
- Keep `moode/` build steps in its own Makefile.
- Format with `alejandra`.

---

<p align="right"><sub><a href="../README.md">← main README</a> · <a href="../server/README.md">server</a> · <a href="../guard/README.md">guard</a></sub></p>
