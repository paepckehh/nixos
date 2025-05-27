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
USELUKS:=YES
DISKOFLAKE:=disko/impermanence-luks.nix
ifeq ($(origin LUKS),undefined)
      USELUKS:=NO
      DISKOFLAKE:=disko/impermanence.nix
endif
OSFLAKE:=/etc/nixos/\#$(TARGET)
WIPEDRIVE?=/dev/null
PATH:=/run/current-system/sw/bin
SUDO:=/run/wrappers/bin/sudo

all:

####################
# USBDRIVE TARGETS #
####################

usb: info check wipe format pre-mount mount post-mount install migrate umount

####################
# USBDRIVE GENERIC #
####################

info: 
	@echo build target drive: /dev/$(TARGETDRIVE), target os: $(TARGET), os-flake: $(OSFLAKE), luks: $(USELUKS), build repo: $(REPO), disko-flake: $(DISKOFLAKE)
	@if [ $(USELUKS) = "YES" ]; then (echo "### LUKS MODE ENABLED, PLEASE ENSURE PROPER DISK/STORAGE LAYOUT IN TARGETOS FLAKE CONFIG!" && sleep 3) ; fi  

check: 
	@if [ ! -e /dev/$(TARGETDRIVE) ]; then (echo "TARGETDRIVE: /dev/$(TARGETDRIVE) does not exists, exit" ; exit 1); fi  

install:
	$(SUDO) nixos-install --verbose --keep-going --impure --no-root-password --root /mnt --flake $(OSFLAKE)
	$(SUDO) git clone $(REPO) /mnt/nix/persist/etc/nixos

pre-mount: 
	$(SUDO) umount -f /mnt/home /mnt/var/lib /mnt/etc/nixos /mnt/etc/ssh /mnt/root/.ssh || true
	$(SUDO) umount -f /mnt/boot /mnt/nix || true
	$(SUDO) umount -f /mnt || true
	$(SUDO) mkdir -p /mnt
	$(SUDO) mount -t tmpfs tmpfs /mnt

mount:
	# XXX TODO
	# $(SUDO) nix run github:nix-community/disko/latest -- --mode mount --argstr diskDevice /dev/$(TARGETDRIVE) $(DISKOFLAKE) || exit 1

post-mount:
	$(SUDO) mkdir -p /mnt/nix/persist/home /mnt/nix/persist/var/lib /mnt/nix/persist/etc/nixos /mnt/nix/persist/etc/ssh /mnt/nix/persist/root/.ssh
	$(SUDO) mkdir -p /mnt/boot /mnt/nix /mnt/home/me /mnt/var/lib /mnt/etc/nixos /mnt/etc/ssh /mnt/root/.ssh 
	$(SUDO) mount -o bind /mnt/nix/persist/home /mnt/home
	$(SUDO) mount -o bind /mnt/nix/persist/var/lib /mnt/var/lib
	$(SUDO) mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
	$(SUDO) mount -o bind /mnt/nix/persist/etc/ssh /mnt/etc/ssh
	$(SUDO) mount -o bind /mnt/nix/persist/root/.ssh /mnt/root/.ssh

umount:
	$(SUDO) sync && sync && sync
	$(SUDO) umount -f /mnt/home /mnt/var/lib /mnt/etc/nixos /mnt/etc/ssh /mnt/root/.ssh  || true
	$(SUDO) umount -f /mnt/boot /mnt/nix || true
	$(SUDO) umount -f /mnt || true
	$(SUDO) rm -rf /mnt /tmp/luks || true

format:
	echo ${LUKS} > /tmp/luks 
	$(SUDO) nix run github:nix-community/disko/latest -- --mode format --argstr diskDevice /dev/$(TARGETDRIVE) $(DISKOFLAKE) || exit 1

wipe:
	$(SUDO) nix run github:nix-community/disko/latest -- --mode destroy --argstr diskDevice /dev/$(TARGETDRIVE) $(DISKOFLAKE) || exit 1
	ZERODRIVE=$(TARGETDRIVE) $(MAKE) trim 

###################
# MIGRATE SECRETS #
###################

migrate: migrate-etcssh migrate-root migrate-me 

migrate-etcssh:
	$(SUDO) mkdir -p /mnt/nix/persist/etc/ssh
	$(SUDO) cp -af /etc/ssh/ssh_host_ed25519* /mnt/nix/persist/etc/ssh/ 
	$(SUDO) chmod 700 /mnt/nix/persist/etc/ssh/ssh_host_ed25519_key
	$(SUDO) chmod 644 /mnt/nix/persist/etc/ssh/ssh_host_ed25519_key.pub
	$(SUDO) chown -R 0:0 /mnt/nix/persist/etc/ssh

migrate-root:
	$(SUDO) cp -rf /root/.ssh /mnt/nix/persist/root/ 
	$(SUDO) chmod 700 /mnt/nix/persist/root/.ssh
	$(SUDO) chmod 600 /mnt/nix/persist/root/.ssh/id_ed25519
	$(SUDO) chmod 644 /mnt/nix/persist/root/.ssh/id_ed25519.pub
	$(SUDO) chmod 644 /mnt/nix/persist/root/.ssh/known_hosts
	$(SUDO) chown -R 0:0 /mnt/nix/persist/root

migrate-me:
	$(SUDO) mkdir -p /mnt/nix/persist/home/me/.local/share
	$(SUDO) cp -rf /home/me/.ssh /mnt/nix/persist/home/me/ 
	$(SUDO) cp -rf /home/me/.local/share/atuin /mnt/nix/persist/home/me/.local/share/
	$(SUDO) chmod 700 /mnt/nix/persist/home/me/.ssh
	$(SUDO) chmod 600 /mnt/nix/persist/home/me/.ssh/pwd.kdbx
	$(SUDO) chmod 600 /mnt/nix/persist/home/me/.ssh/id_ed25519
	$(SUDO) chmod 644 /mnt/nix/persist/home/me/.ssh/id_ed25519.pub
	$(SUDO) chmod 644 /mnt/nix/persist/root/.ssh/known_hosts
	$(SUDO) chown -R me:me /mnt/nix/persist/home/me

#################
# LITTLE HELPER #
#################

sda-zero: 
	ZERODRIVE=sda $(MAKE) zero trim
sdb-zero: 
	ZERODRIVE=sdb $(MAKE) zero trim
sdc-zero: 
	ZERODRIVE=sdc $(MAKE) zero trim 
trim:
	$(SUDO) blkdiscard -f /dev/$(ZERODRIVE) > /dev/null || true
	$(SUDO) nvme format /dev/$(ZERODRIVE) --force > /dev/null || true
zero: 
	$(SUDO) dd if=/dev/zero of=/dev/$(ZERODRIVE) oflag=direct bs=512k status=progress
	$(SUDO) dd if=/dev/zero of=/dev/$(ZERODRIVE) oflag=direct bs=512k status=progress
