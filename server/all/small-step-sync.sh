#!/bin/sh
# manual: mv /root/.step/* /var/lib/private/step-ca/
sudo -v || exit 1
sudo cp -a /etc/smallstep/ca.json /var/lib/private/step-ca/config/ca.json
sudo chown -R step-ca:step-ca /var/lib/private/step-ca
sudo systemctl restart step-ca.service
sudo systemctl restart caddy.service
