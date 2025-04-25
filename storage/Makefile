#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

######################
# SETUP ENV DEFAULTS #
######################
REPO?=https://github.com/paepckehh/nixos
TARGET?=nixusb

all:

###################
# INSTALL TARGETS #
###################

sdb: sdb-prep sdb-mount install sdb-umount
sdb-clean: sdb-wipe sdb 

sdb-prep:
	sudo nix run github:nix-community/disko/latest -- --mode destroy disko-lvm-prep-sdb.nix
	sudo nix run github:nix-community/disko/latest -- --mode format disko-lvm-prep-sdb.nix

sdb-mount: 
	sudo mkdir  -p /mnt/boot /mnt/home /mnt/nix /mnt/var
	sudo umount -f /mnt/boot /mnt/home /mnt/nix /mnt/var > /dev/null 2>&1 || true
	sudo mount /dev/usbpool/home /mnt/home
	sudo mount /dev/usbpool/nix  /mnt/nix
	sudo mount /dev/usbpool/var  /mnt/var
	sudo mount /dev/sdb1  /mnt/boot

sdb-umount:
	sudo sync && sync && sync
	sudo umount -f /mnt/boot /mnt/home /mnt/nix /mnt/var > /dev/null 2>&1 || true
	sudo rm -rf /mnt

sdb-wipe:
	sudo dd if=/dev/zero of=/dev/sdb bs=512k oflag=direct status=progress  || true
	sudo dd if=/dev/zero of=/dev/sdb bs=512k oflag=direct status=progress  || true

###########
# GENERIC #
###########

install:
	sudo nixos-install --verbose --root /mnt --flake "/etc/nixos/#$(TARGET)"
	sudo git clone $(REPO) /mnt/etc/nixos
