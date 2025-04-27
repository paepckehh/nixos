#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

######################
# SETUP ENV DEFAULTS #
######################
REPO?=https://github.com/paepckehh/nixos
TARGETOS?=${TARGETOS}
DEVICE_MAIN:=$(TARGETDRIVE)

all:

####################
# USBDRIVE TARGETS #
####################

usb: info wipe format pre-mount mount post-mount 
32: install umount

####################
# USBDRIVE GENERIC #
####################

info:
	echo build target drive: /dev/$(TARGETDRIVE), target os: $(TARGETOS), build repo: $(REPO)

install:
	sudo nixos-install --verbose --impure --no-root-password --root /mnt --flake "/etc/nixos/#$(TARGETOS)" # impure is needed for agenix
	sudo git clone $(REPO) /mnt/etc/nixos

pre-mount: 
	sudo mkdir  -p /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/var/log /mnt/nix/var/log /mnt/etc/nixos
	sudo umount -f /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/nix/var/log /mnt/var/log /mnt > /dev/null 2>&1 || true
	sudo umount -f /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/nix/var/log /mnt/var/log /mnt > /dev/null 2>&1 || true

post-mount:
	sudo mkdir  -p /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/var/log /mnt/nix/var/log /mnt/etc/nixos 
	sudo mkdir  -p /mnt/nix/persist/home /mnt/nix/persist/var/log /mnt/nix/persist/etc/nixos 
	sudo mount -o bind /mnt/nix/persist/var /mnt/var
	sudo mount -o bind /mnt/nix/persist/home /mnt/home
	sudo mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
	sudo mount -t tmpfs tmpfs /mnt/var/log
	sudo mount -t tmpfs tmpfs /mnt/nix/var/log

umount:
	sudo sync && sync && sync
	sudo umount -f /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/nix/var/log /mnt/var/log /mnt > /dev/null 2>&1 || true
	sudo umount -f /mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/nix/var/log /mnt/var/log /mnt > /dev/null 2>&1 || true
	sudo rm -rf /mnt || true

format:
	sudo nix run github:nix-community/disko/latest -- --mode format flakes/disko-impermanence-$(TARGETDRIVE).nix

mount:
	sudo nix run github:nix-community/disko/latest -- --mode mount flakes/disko-impermanence-$(TARGETDRIVE).nix

wipe:
	sudo nix run github:nix-community/disko/latest -- --mode destroy flakes/disko-impermanence-$(TARGETDRIVE).nix
	sudo nvme format --verbose /dev/$(TARGETDRIVE) --force || true
