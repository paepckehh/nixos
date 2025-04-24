#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

all:

sdb: sdb-prep sdb-mount install

sdb-prep:
	sudo nix run github:nix-community/disko/latest -- --mode destroy disko-lvm-prep-sdb.nix
	sudo sync && sudo sync && sudo sync
	sudo nix run github:nix-community/disko/latest -- --mode format disko-lvm-prep-sdb.nix
	sudo sync && sudo sync && sudo sync

sdb-mount:
	sudo umount -f /mnt/boot /mnt/home /mnt/nix /mnt/var > /dev/null 2>&1 || true
	sudo mkdir  -p /mnt/boot /mnt/home /mnt/nix /mnt/var
	sudo mount /dev/usbpool/home /mnt/home
	sudo mount /dev/usbpool/nix  /mnt/nix
	sudo mount /dev/usbpool/var  /mnt/var
	sudo mount /dev/sdb1  /mnt/boot

wipe-sdb:
	sudo dd if=/dev/zero of=/dev/sdb bs=512k oflag=direct status=progress count=128

install:
	sudo nixos-install --verbose --root /mnt --flake "/etc/nixos/#nixusb"

