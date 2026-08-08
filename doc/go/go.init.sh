#!/bin/sh
#
if [ -x /nix/persist/cache/go/cache ]; then exit 0; fi
#
sudo -v
set -v -x
#
sudo mkdir -p /nix/persist/bin
sudo chown -R 0:0 /nix/persist/bin
sudo chmod -R 755 /nix/persist/bin
#
TARGET="/nix/persist/cache/go"
SUBDIRS="cache go-path path pkg"
sudo rm -rf $TARGET >/dev/null 2>&1 || true
sudo mkdir -p $TARGET
sudo chown -R 0:users $TARGET
sudo chmod -R 644 $TARGET
sudo chmod 755 $TARGET
for subdir in $SUBDIRS; do
	sudo mkdir -p "$TARGET/$subdir"
	sudo chmod 755 "$TARGET/$subdir"
done
