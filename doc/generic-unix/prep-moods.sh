#!/bin/sh
sudo mkdir -p /tmp/moods-root || exit 1
sudo mount /dev/sdb2 /tmp/moods-root || exit 1
sudo cp -af /etc/nixos/generic-unix/* /tmp/moods-root/
sudo chown -R 0:0 /tmp/moods-root/etc
sudo chown 0:0 /tmp/moods-root/home
sudo chown me:me /tmp/moods-root/home/me
sudo chmod 0600 /tmp/moods-root/root/.ssh/authorized_keys
sudo chmod 0600 /tmp/moods-root/home/me/.ssh/authorized_keys
sudo rm /tmp/moods-root/prep-moods.sh
sync
