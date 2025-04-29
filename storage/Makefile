#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

######################
# SETUP ENV DEFAULTS #
######################
REPO?=https://github.com/paepckehh/nixos
TARGET?=$(shell hostname)
TARGETDRIVE?=sdb
DEVICE_MAIN:=$(TARGETDRIVE)
STRUCT:=/mnt/boot /mnt/nix /mnt/home /mnt/var/lib /mnt/etc/nixos /mnt/etc/ssh /mnt/nix/var/log /mnt
PERSIST:=/mnt/nix/persist/home /mnt/nix/persist/var/lib /mnt/nix/persist/etc/nixos /mnt/nix/persist/etc/ssh
USELUKS:=YES
FLAKE:=flakes/disko-impermanence-luks-$(TARGETDRIVE).nix
ifeq ($(origin LUKS),undefined)
      USELUKS:=NO
      FLAKE:=flakes/disko-impermanence-$(TARGETDRIVE).nix
endif
WIPEDRIVE?=/dev/null

all:

####################
# USBDRIVE TARGETS #
####################

usb: info check wipe format pre-mount mount post-mount # install umount

####################
# USBDRIVE GENERIC #
####################

info: 
	@echo build target drive: /dev/$(TARGETDRIVE), target os: $(TARGET), luks: $(USELUKS), build repo: $(REPO), flake: $(FLAKE)

check: 
	@if [ ! -e /dev/$(TARGETDRIVE) ]; then (echo "TARGETDRIVE: /dev/$(TARGETDRIVE) does not exists, exit" ; exit 1); fi  

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
	sudo mkdir -p /mnt
	sudo mount -t tmpfs tmpfs /mnt

post-mount:
	sudo mkdir -p $(STRUCT) 
	sudo mkdir -p $(PERSIST)
	sudo mount -o bind /mnt/nix/persist/var/lib /mnt/var/lib
	sudo mount -o bind /mnt/nix/persist/home /mnt/home
	sudo mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
	sudo mount -o bind /mnt/nix/persist/etc/ssh /mnt/etc/ssh
	sudo mount -t tmpfs tmpfs /mnt/nix/var/log

umount:
	sudo sync && sync && sync
	sudo umount -f $(STRUCT) > /dev/null 2>&1 || true
	sudo umount -f $(STRUCT) > /dev/null 2>&1 || true
	sudo umount -f /mnt > /dev/null 2>&1 || true
	sudo rm -rf /mnt /tmp/luks > /dev/null 2>&1 || true

format:
	echo ${LUKS} > /tmp/luks 
	sudo nix run github:nix-community/disko/latest -- --mode format $(FLAKE) || exit 1

mount:
	sudo nix run github:nix-community/disko/latest -- --mode mount $(FLAKE) || exit 1 

wipe:
	sudo nix run github:nix-community/disko/latest -- --mode destroy $(FLAKE) || exit 1
	sudo nvme format --verbose /dev/$(TARGETDRIVE) --force || true


##################
# GENERIC HELPER #
##################

sda-zero: 
	ZERODRIVE=/dev/sda $(MAKE) zero
sdb-zero: 
	ZERODRIVE=/dev/sdb $(MAKE) zero
sdc-zero: 
	ZERODRIVE=/dev/sdc $(MAKE) zero

zero: 
	sudo dd if=/dev/zero of=$(ZERODRIVE) oflag=direct bs=512k status=progress
	sudo dd if=/dev/zero of=$(ZERODRIVE) oflag=direct bs=512k status=progress
