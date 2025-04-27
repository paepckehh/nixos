#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

# DEFAULTS
ID:=$(shell id -u)
GID:=$(shell id -g)
ISO?=iso
TARGET?=$(shell hostname)
DTS:=$(shell date '+%Y-%m-%d-%H-%M')
FLAKE:="/etc/nixos/.\#$(TARGET)"
PROFILE:="$(TARGET)-$(DTS)"
TYPE:="nixos boot profile"

###########
# GENERIC #
###########

all:
	@echo "STATUS # $(MAKE) # ID: $(ID) # GID: $(GID) # TARGET: $(TARGET) # DTS: $(DTS) # PROFILE: $(PROFILE) # FLAKE: $(FLAKE)"
	@echo "Set TARGET='hostname' to build for a specific host target. Your current target TARGET=$(TARGET)."
	@echo "Set ISO='<image-variant>' to build a specific image type. Defaults to 'iso'. Run: make info-image to see all formats."

info:
	@echo "Building for target TARGET=$(TARGET)"
	@echo -e "Your new $(TYPE) ==> $(PROFILE) =======> \033[48;5;57m   $(PROFILE)   \033[0m <=========="
	
info-image:
	sudo nixos-rebuild build-image --flake $(FLAKE)  || true

####################
# NIXOS OPERATIONS #
####################

build:  info commit build-log
	sudo nixos-rebuild boot --flake $(FLAKE) --profile-name $(PROFILE)

check: info
	sudo nix flake check 
	sudo alejandra --quiet .

switch: info commit build-log
	sudo nixos-rebuild switch --flake $(FLAKE) --profile-name $(PROFILE)

update: info commit  
	mkdir -p .attic/flake.lock
	cp -f flake.lock .attic/flake.lock/$(DTS).flake.lock
	nix flake update
        
bootloader: info commit 
	sudo nixos-rebuild boot -v --fallback --install-bootloader

test: info commit build-log
	sudo nixos-rebuild dry-activate --flake $(FLAKE)

offline: info commit 
	# XXX broken: fixme 
	sudo nixos-rebuild boot -v --option use-binary-caches false --flake $(FLAKE) --profile-name $(PROFILE)
      
rollback: info commit
	# XXX broken: fixme 
	sudo nixos-rebuild switch --rollback 

build-log:
	sudo nom build ".#nixosConfigurations.$(TARGET).config.system.build.toplevel"
	@sudo rm -rf result

#################
# NIXOS INSTALL #
#################

# install optimized usbdrive live os
# set env TARGETOS for other target-os, default: current-system [$hostname]
# set TARGETDRIVE for usb stick, default: sdb [uses: /dev/sdb] [supports: sda, sdb and sdc]
TARGETDRIVE?=sdb

sda: info commit
	export TARGET=$(TARGET)
	export TARGETDRIVE=sda
	${MAKE} -C storage usb

sdb: info commit
	export TARGET=$(TARGET)
	${MAKE} -C storage usb

sdc: info commit 
	export TARGET=$(TARGET)
	export TARGETDRIVE=sdc
	${MAKE} -C storage usb

usb: info commit
	export TARGET=$(TARGET)
	export TARGETDRIVE=$(TARGETDRIVE)
	${MAKE} -C storage usb

# make full automatic bootable iso (offline-) installer for current system,
# set env TARGET for other nix flake target systems
installer: info commit 
	NIXPKGS_ALLOW_BROKEN=1 nix build -L ".#nixosConfigurations.iso-installer.config.system.build.isoImage"
	ls -la /etc/nixos/result/iso

# XXX maybe broken: fixme, needs validation
# make live iso image from current system, set env TARGET for other nix flake target systems
iso: info commit
	sudo nixos-rebuild build-image --flake $(FLAKE) --image-variant iso
	ls -la /etc/nixos/result/iso

# umount /mnt build struct
umount: commit 
	${MAKE} -C storage umount

#######################
# NIX REPO OPERATIONS #
#######################

push: pre-commit 
	git add .
	git commit -S -m update
	git push --force 

commit: pre-commit
	git add .
	-git commit --quiet -m 'update' > /dev/null 2>&1 || true

pre-commit:
	@-sudo rm -rf result > /dev/null 2>&1 || true
	@sudo chown -R $(ID):$(GID) *
	@sudo chown -R $(ID):$(GID) .git 
	@alejandra --quiet .

followremote: 
	@git reset --hard
	@git clean --force 
	@git checkout --force .
	@git config pull.ff only
	git pull --ff --force 
	@git-gc

git-gc: commit 
	git reflog expire --expire-unreachable=now --all 
	git gc --aggressive --prune=now 
	git fsck --full 


########################
# NIX STORE OPERATIONS #
########################

clean: internal-clean-12d build gc 

clean-hard: internal-clean-profiles internal-clean-1d build gc

clean-profiles: internal-clean-profiles build

cache: update build-nixos-all sign

build-nixos-all:
	nixos-rebuild build -v --fallback --flake "/etc/nixos/#nixos-all"
	rm -rf result

sign:
	sudo nix store sign --all --key-file /var/cache-priv-key.pem

gc: git-gc 
	sudo nix-store --gc
	sudo nix-store --optimise

repair: store-gc
	sudo nix-store --verify --check-contents --repair

internal-clean-1d:
	sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 1d
	sudo nix-collect-garbage --delete-older-than 1d

internal-clean-12d: 
	sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 12d
	sudo nix-collect-garbage --delete-older-than 12d 

internal-clean-profiles:
	sudo rm -rf /boot/loader/entries || true
	sudo rm -rf /nix/var/log/nix || true
	sudo rm -rf /nix/var/nix/profiles/system* || true
	sudo mkdir -p /boot/loader/entries 
	sudo chmod -R 700 /boot/loader/entries
	sudo mkdir -p /nix/var/log/nix/drvs
	sudo mkdir -p /nix/var/nix/profiles/system-profiles
