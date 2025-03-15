#!/bin/sh
USER="me"
KEYNAME="id_ed25519_sk"
TARGET="/home/$USER/.ssh"
SOURCE="/etc/nixos/person/resources/smartcard/mpaepcke/.ssh"
sudo -v && {
	sudo mkdir -p $TARGET
	sudo cp -af $SOURCE/$KEYNAME $TARGET/$KEYNAME
	sudo cp -af $SOURCE/$KEYNAME.pub $TARGET/$KEYNAME.pub
	sudo chown -R $USER:users $TARGET
	sudo chmod 600 $TARGET/$KEYNAME
	sudo chmod 644 $TARGET/$KEYNAME.pub
}
