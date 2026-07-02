# 🏠 IoT — Smart Device Integrations

> EcoFlow power stations, Home Assistant hubs, Tibber energy monitors, Moode audio players, DAB receivers — all managed through NixOS module definitions.

---

## 🗂️ What's In Here

IoT module definitions that integrate physical devices with the infrastructure. Each file describes one device family as a NixOS service profile.

| File | Device | Purpose |
|---|---|---|
| `dab.nix` | DAB Radio Receiver | DAB/DAB+ digital radio streaming & control |
| `ecoflow-mqtt.nix` | EcoFlow Power Station | MQTT-based telemetry: battery, solar input, device status |
| `ecoflow-rest.nix` | EcoFlow Power Station | REST API integration: email notifications, access keys, device management |
| `homeassistant.nix` | Home Assistant | Smart home hub — Home Assistant integration & automation |
| `tibber.nix` | Tibber Energy Monitor | Smart meter integration: real-time energy prices, consumption tracking |

### Audio

| Directory | Contents |
|---|---|
| `moode/` | Moode Audio player — Makefile, stream aliases, manual notes |

---

## 🔌 Integration Pattern

Each IoT module defines:

```nix
{ config, pkgs, lib, ... }:
let
  infra = (import ../siteconfig/config.nix).infra;
in {
  # Service definition
  services.<device> = {
    enable = true;
    settings = { ... };
  };

  # Secrets from modules/resources/
  secrets = import ../modules/resources/<device>.age;
}
```

## 🔐 Secrets

IoT devices often need API keys, tokens, or credentials. These are stored as encrypted `.age` files:

- `ecoflow-email.age` — EcoFlow account email
- `ecoflow-access-key.age` — API access key
- `ecoflow-secret-key.age` — API secret key
- `ecoflow-devices.age` — Device registry
- `tibber.age` — Tibber API token

---

## 📊 Data Flow

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────┐
│ EcoFlow     │     │ Home         │     │ Tibber            │
│ Power       │──>──│ Assistant    │──>──│ Smart Meter       │
│ Station     │     │ (Hub)        │     │                   │
└─────────────┘     └──────────────┘     └───────────────────┘
                          │                      │
                     ┌────▼──────┐         ┌─────▼───────┐
                     │ NixOS     │         │ Prometheus  │
                     │ Monitor   │         │ + Grafana   │
                     └───────────┘         └─────────────┘
```

---

*For monitoring services → [Server/monitoring](../server/monitoring/)*
*For secrets → [modules/resources](../modules/resources/)*
