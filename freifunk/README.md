# Freifunk

<div align="center">

**A community-run, decentralized wireless mesh network for Lübeck**

[![Mesh Map](https://img.shields.io/badge/📍_Mesh_Map-Live-43B02A?style=for-the-badge)](https://map.luebeck.freifunk.net)
[![Monitoring](https://img.shields.io/badge/📊_Monitoring-Live-43B02A?style=for-the-badge)](https://monitoring.freifunknord.de)
[![IRC](https://img.shields.io/badge/💬_IRC-hackint%20%23ffhl-43B02A?style=for-the-badge&logo=irc)](irc://irc.hackint.org/#ffhl)

</div>

## What is Freifunk?

Freifunk is a **citizen-initiated project** to build a community-wide, wireless mesh network using commodity WLAN routers. Volunteers install and operate nodes throughout the city, creating a **free, decentralized, community-run network** that anyone can connect to with a Wi-Fi device.

> Freifunk operates on the principle of **[network commons](https://wiki.luebeck.freifunk.net)** — voluntary giving and receiving as described in the [Pico Peering Agreement](https://picopeering.org/).

### How It Works

1. 📡 **Install** — A volunteer sets up a Freifunk router at their location
2. 🌐 **Mesh** — Nodes connect to each other wirelessly, forming an overlay network
3. 🔓 **Connect** — Anyone nearby can join the network for free
4. 🌍 **Peer** — Through our [national peering agreement](https://wiki.freifunk.net), we share internet access with other Freifunk communities

## Resources

| Resource | Link |
| --- | --- |
| 🌐 National Freifunk | [freifunk.net](https://freifunk.net) · [wiki.freifunk.net](https://wiki.freifunk.net) |
| 🏘️ Freifunk Lübeck | [luebeck.freifunk.net](https://luebeck.freifunk.net) · [wiki.luebeck.freifunk.net](https://wiki.luebeck.freifunk.net) |
| 📍 Community Map | [map.luebeck.freifunk.net](https://map.luebeck.freifunk.net) |
| 📊 Network Monitoring | [monitoring.freifunknord.de](https://monitoring.freifunknord.de) |

## Get Involved

- 💬 **Chat:** Join us on [Matrix](https://matrix.to/#/#freifunk-luebeck:matrix.org) or [IRC](irc://irc.hackint.org/#ffhl)
- 🤝 **Meetups:** Monthly meetups at [Nobreakspace / Chaotikum e.V.](https://chaotikum.de), Lübeck
- 🛠️ **Contribute:** Help us improve our [NixOS router images](#nixos-images)

## NixOS Images

We provide automated NixOS-based firmware builds for supported router hardware.

```bash
curl https://res.<brand>.corp/freifunk/<model>.latest
```

📦 **Download images:** [res.home.corp/freifunk](https://res.home.corp/freifunk)
