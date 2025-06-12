## noc-box.de 

## Business Targets 

- turn people & hours into scalable subscription services 

## Tech Stack ( raw brain dump  / stichpunkte / ungefiltert )

### Free Tier [Level 0 & 1]
- Kundenbindungsmassnahme / Kompetenz Demonstration
- Geringes wirtschaftliches risko - geringe externe monatliche externe kosten 
- Free Tier Services (similar too google dns, google gmail-beta) ermoeglicht plattform lock-in, ohne selbst SLAs liefern zu muessen
- (Minimal/Startup) Backend Infrastruktur:
    - 2x MicroVM VPS, 2vCPU, 2GB RAM (ab 3,50 EUR / Monat / vps, z.b. Hetzner VPS CX22)
    - 1x Central Management & DB server (DB/Storage/Postgres/Prometheus,Grafana bei data stodo?) 
    - ausreichend fuer mehrere hundert DSS IT Security Mandanten mit je vielen hundert Mitarbeitern
    - Tech-stack, initial: keep it stupid simple and robust (linux/unbound)
    - 100 % Open Source, preference on EU based Open Source Projects
    - central managed declarative nixos config (read-only vps images)
    - https://nixos.org, implementation samples eigener hosts https://github.com/paepckehh/nixos 
    - minimal hardened kernel rump, systemd-initrd, unbound recursive dns resolver, dnstap raw logging 
    - no userland, no ssh, no local accounts, no storage
    - read-only and stateless micro vps images, can be build for x86, arm64, risc64 
    - downside: update requires reboot (cache loss)
    - unbound and linux os plattform monitoring & alerting via prometheus time series db
    - bussiness dashboards via prometgeus & grafana
    - example: https://github.com/ar51an/unbound-dashboard/blob/main/screenshots/dashboard-2.3.png 
    - wenn erfolgreich, scaling via cloudflare battle-proven dns tech stack moeglich (All EU, All Open Source: knot-resolver,pdns)
    - dnscrypt, dnstap linux/nixos integration PRs WIP https://github.com/NixOS/nixpkgs/pulls?q=is%3Apr+author%3Apaepckehh+

### NOC BOX [Level Entry] 
- DNS cache / forwarder / self-hosted netzwerk monitoring ist problemlos mit simplen thin clients (on-premise) moeglich
- Hardware EK: 30 bis 80 EUR incl. / macht einen VK: 100 bis 150 (selbstkosen-preis) moeglich
    - https://www.ram-koenig.de/dell-wyse-3040-mini-pc-x5-z8350-9d3fh
    - https://www.ram-koenig.de/dell-wyse-5070-tc-intel-j4105-n11d001-914nxpsu
    - branding
- lokales web-gui, abgestufes rechtekonzept, 100% lokale kontrolle, DSS IT Branding moeglich
- example: https://github.com/OliveTin/OliveTin/blob/main/var/marketing/screenshotDesktop.png 

### NOC BOX [Level Full-Service]
- Enables Advanced Corporate Service Level Applications
- tbd

### NOC BOX [Level Enterprise]
- 19 Zoll rack-able
- tbd

### Perspektive
- intrgration weiterer hosted SOC services (LAN, WAN, NAC monitoring)
- on-site log aggregator, filter, forward events -> DSS IT Security Wazuh SOC / Team
