#!/bin/sh
sudo -v || exit 1
sudo cp -a /etc/smallstep/ca.json /var/lib/private/step-ca/config/ca.json
