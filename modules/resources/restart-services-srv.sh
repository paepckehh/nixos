#!/bin/sh
sudo -v
set -o verbose
sudo systemctl stop nginx.service
sudo systemctl restart bind.service
sudo systemctl restart step-ca.service
sudo systemctl restart lldap.service
sudo systemctl restart authelia-home.service
sudo systemctl restart searx-init.service
sudo systemctl restart searx.service
# sudo systemctl restart container@miniflux.service
# sudo systemctl restart container@immich.service
# sudo systemctl restart container@nextcloud.service
# sudo systemctl restart onlyoffice-docservice.service
# sudo systemctl restart maddy.service
# sudo systemctl restart nextcloud-setup.service
# sudo systemctl restart tuwunel.service
# sudo systemctl restart uptime-kuma.service
# sudo systemctl restart prometheus.service
# sudo systemctl restart vaultwarden.service
# sudo systemctl restart readeck.service
# sudo systemctl restart open-webui.service
# sudo systemctl restart nextcloud-update-db.service
# sudo systemctl restart redis-nextcloud.service
# sudo systemctl restart nextcloud-cron.service
# sudo systemctl restart redis-zammad.service
# sudo systemctl restart zammad-websocket.service
# sudo systemctl restart zammad-worker.service
# sudo systemctl restart zammad-web.service
# sudo systemctl restart redis-paperless.service
# sudo systemctl restart paperless-consumer.service
# sudo systemctl restart paperless-exporter.service
# sudo systemctl restart paperless-task-queue.service
# sudo systemctl restart paperless-web.service
# sudo systemctl restart forgejo-secrets.service
# sudo systemctl restart forgejo.service
# sudo systemctl restart stirling-pdf.service
# sudo systemctl restart prometheus-node-exporter.service
# sudo systemctl restart prometheus-smartctl-exporter.service
# sudo systemctl restart grafana.service
# sudo systemctl restart podman.service
# sudo systemctl restart podman-netalertx.service
# sudo systemctl restart podman-speed.service
# sudo systemctl restart podman-chef.service
# sudo systemctl restart podman-meshtastic-web.service
sudo systemctl stop nginx.service
sudo systemctl restart caddy.service
sudo systemctl restart nginx.service
