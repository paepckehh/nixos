#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

######################
# SETUP ENV DEFAULTS #
######################
REPO?=https://github.com/paepckehh/nixos
TARGET?=${TARGET}
DEVICE_MAIN:=$(TARGETDRIVE)
STRUCT:=/mnt/boot /mnt/nix /mnt/home /mnt/var /mnt/etc/nixos /mnt/etc/ssh /mnt/nix/var/log /mnt/var/log /mnt
PERSIST:=/mnt/nix/persist/home /mnt/nix/persist/var/log /mnt/nix/persist/etc/nixos /mnt/nix/persist/etc/ssh

all:

####################
# USBDRIVE TARGETS #
####################

usb: info wipe format pre-mount mount post-mount install umount

####################
# USBDRIVE GENERIC #
####################

info:
	echo build target drive: /dev/$(TARGETDRIVE), target os: $(TARGET), build repo: $(REPO)

install:
	sudo nixos-install --verbose --impure --no-root-password --root /mnt --flake "/etc/nixos/#$(TARGET)" # impure is needed for agenix
	sudo git clone $(REPO) /mnt/etc/nixos
	sudo mkdir -p /mnt/home/me/.ssh /mnt/etc/ssh
	sudo cp -af /home/me/.ssh/id_ed22519* /mnt/home/me/.ssh/ > /dev/null 2>&1 || true # yubikey glue records
	sudo cp -af /etc/ssh/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_ed25519_key > /dev/null 2>&1 || true # agenix

pre-mount: 
	sudo mkdir  -p $(STRUCT)
	sudo umount -f $(STRUCT) > /dev/null 2>&1 || true
	sudo umount -f $(STRUCT) > /dev/null 2>&1 || true

post-mount:
	sudo mkdir -p $(STRUCT) $(PERSIST)
	sudo mount -o bind /mnt/nix/persist/var /mnt/var
	sudo mount -o bind /mnt/nix/persist/home /mnt/home
	sudo mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
	sudo mount -o bind /mnt/nix/persist/etc/ssh /mnt/etc/ssh
	sudo mount -t tmpfs tmpfs /mnt/var/log
	sudo mount -t tmpfs tmpfs /mnt/nix/var/log

umount:
	sudo sync && sync && sync
	sudo umount -f $(STRUCT) > /dev/null 2>&1 || true
	sudo umount -f $(STRUCT) > /dev/null 2>&1 || true
	sudo rm -rf /mnt || true

format:
	sudo nix run github:nix-community/disko/latest -- --mode format flakes/disko-impermanence-$(TARGETDRIVE).nix

mount:
	sudo nix run github:nix-community/disko/latest -- --mode mount flakes/disko-impermanence-$(TARGETDRIVE).nix

wipe:
	sudo nix run github:nix-community/disko/latest -- --mode destroy flakes/disko-impermanence-$(TARGETDRIVE).nix
	sudo nvme format --verbose /dev/$(TARGETDRIVE) --force || true
