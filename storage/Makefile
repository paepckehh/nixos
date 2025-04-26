#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

######################
# SETUP ENV DEFAULTS #
######################
REPO?=https://github.com/paepckehh/nixos
TARGET?=nixusb
IMPERMANENCE?=disko-impermanence.nix

all:

###################
# INSTALL TARGETS #
###################

sdb: sdb-wipe sdb-format sdb-mount install umount
sdb-hardclean: sdb-zero sdb 

sdb-wipe:
	sudo nvme format /dev/sdb --force || true
	sudo nix run github:nix-community/disko/latest -- --mode destroy $(IMPERMANENCE)

sdb-format:
	sudo nix run github:nix-community/disko/latest -- --mode format $(IMPERMANENCE)

sdb-mount: 
	sudo mkdir  -p /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/var/log /mnt/nix/var/log /mnt/etc/nixos
	sudo umount -f /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/nix/var/log /mnt/var/log /mnt > /dev/null 2>&1 || true
	sudo umount -f /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/nix/var/log /mnt/var/log /mnt > /dev/null 2>&1 || true
	sudo nix run github:nix-community/disko/latest -- --mode mount $(IMPERMANENCE)
	sudo mkdir  -p /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/var/log /mnt/nix/var/log /mnt/etc/nixos 
	sudo mkdir  -p /mnt/nix/persist/home /mnt/nix/persist/var/log /mnt/nix/persist/etc/nixos 
	sudo mount -o bind /mnt/nix/persist/var /mnt/var
	sudo mount -o bind /mnt/nix/persist/home /mnt/home
	sudo mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
	sudo mount -t tmpfs tmpfs /mnt/var/log
	sudo mount -t tmpfs tmpfs /mnt/nix/var/log

sdb-zero:
	sudo dd if=/dev/zero of=/dev/sdb bs=512k oflag=direct status=progress  || true
	sudo dd if=/dev/zero of=/dev/sdb bs=512k oflag=direct status=progress  || true

######################
# GENERIC OS INSTALL #
######################

install:
	sudo nixos-install --verbose --no-root-password --root /mnt --flake "/etc/nixos/#$(TARGET)"
	sudo git clone $(REPO) /mnt/etc/nixos

umount:
	sudo sync && sync && sync
	sudo umount -f /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/nix/var/log /mnt/var/log /mnt > /dev/null 2>&1 || true
	sudo umount -f /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/nix/var/log /mnt/var/log /mnt > /dev/null 2>&1 || true
	sudo rm -rf /mnt || true
