#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

# DEFAULTS
ID:=$(shell id -u)
GID:=$(shell id -g)
NAME:=$(shell id -nu)
ISO?=iso
PARALLEL?=0
TARGET?=$(shell /run/current-system/sw/bin/hostname)
DTS:=$(shell date '+%Y-%m-%d-%H-%M')
OSFLAKE:=/etc/nixos/\#$(TARGET)
ALLFLAKE:=/etc/nixos/.\#nixos-all
PROFILE:="$(TARGET)-$(DTS)"
TYPE:="nixos boot profile"
USELUKS:=YES
ifeq ($(origin LUKS),undefined)
      USELUKS:=NO
endif
PATH:=/run/current-system/sw/bin
SUDO:=/run/wrappers/bin/sudo

###########
# GENERIC #
###########

all:
	@echo "STATUS # $(MAKE) # ID: $(ID) # GID: $(GID) # TARGET: $(TARGET) # LUKS: $(USELUKS) # DTS: $(DTS) # PROFILE: $(PROFILE) # OSFLAKE: $(OSFLAKE)"
	@echo "Set TARGET='hostname' to build for a specific host target. Your current target TARGET=$(TARGET)."
	@echo "Set ISO='<image-variant>' to build a specific image type. Defaults to 'iso'. Run: make info-image to see all formats."
	@echo "Set TARGETDISK='sdb' to build live-os on a specific target disk." 
	@echo "Set LUKS='<secret>' to enable hardened luks fde during new disk build."

info:
	@echo "Building for target TARGET=$(TARGET)"
	@echo -e "Your new $(TYPE) ==> $(PROFILE) =======> \033[48;5;57m   $(PROFILE)   \033[0m <=========="

info-cleaninstall:
	@echo "Building for target TARGET=$(TARGET) # Building on TARGETDRIVE=$(TARGETDRIVE) # Using LUKS: $(USELUKS) # OSFLAKE: $(OSFLAKE)"

info-iso-installer:
	@echo "Building iso-auto-installer ..."
	
info-image:
	$(SUDO) nixos-rebuild build-image --flake $(OSFLAKE)  || true

####################
# NIXOS OPERATIONS #
####################

boot:   build 

build:  info commit build-log
	$(SUDO) nixos-rebuild boot --flake $(OSFLAKE) --profile-name $(PROFILE)

check: info
	nix flake check 
	alejandra --quiet .

switch: info commit build-log
	$(SUDO) nixos-rebuild switch --flake $(OSFLAKE) --profile-name $(PROFILE)

update: commit  
	mkdir -p .attic/flake.lock
	cp -f flake.lock .attic/flake.lock/$(DTS).flake.lock
	nix flake update
        
bootloader: info commit 
	$(SUDO) nixos-rebuild boot -v --fallback --install-bootloader

test: commit build-log
	nixos-rebuild dry-activate --flake $(OSFLAKE)

offline: info commit 
	# XXX broken: fixme 
	$(SUDO) nixos-rebuild boot -v --flake $(OSFLAKE) --profile-name $(PROFILE)
      
rollback: commit
	# XXX broken: fixme 
	$(SUDO) nixos-rebuild switch --rollback 

build-log:
	nom build ".#nixosConfigurations.$(TARGET).config.system.build.toplevel"
	@$(SUDO) rm -rf result


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
	@-$(SUDO) rm -rf result > /dev/null 2>&1 || true
	@$(SUDO) chown -R me:me *
	@$(SUDO) chown -R me:me .git 
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
	nixos-rebuild build -v --fallback --flake $(ALLFLAKE)
	rm -rf result

sign:
	nix store sign --all --key-file /var/cache-priv-key.pem

gc: git-gc 
	nix-store --gc
	nix-store --optimise

repair: store-gc
	nix-store --verify --check-contents --repair

internal-clean-1d:
	nix-env --delete-generations --profile /nix/var/nix/profiles/system 1d
	nix-collect-garbage --delete-older-than 1d

internal-clean-12d: 
	nix-env --delete-generations --profile /nix/var/nix/profiles/system 12d
	nix-collect-garbage --delete-older-than 12d 

internal-clean-profiles:
	$(SUDO) -v || exit 1
	$(SUDO) rm -rf /boot/loader/entries || true
	$(SUDO) rm -rf /nix/var/log/nix || true
	$(SUDO) rm -rf /nix/var/nix/profiles/system* || true
	$(SUDO) mkdir -p /boot/loader/entries 
	$(SUDO) chmod -R 700 /boot/loader/entries
	$(SUDO) mkdir -p /nix/var/log/nix/drvs
	$(SUDO) mkdir -p /nix/var/nix/profiles/system-profiles

#################
# NIXOS INSTALL #
#################

# install optimized usbdrive live os
# set env TARGETOS for other target-os, default: current-system [$hostname]
# set TARGETDRIVE for usb stick, default: sdb [uses: /dev/sdb] [supports: sda, sdb and sdc]
TARGETDRIVE?=sdb

sda: info-cleaninstall commit
	export PARALLEL=1
	export TARGETDRIVE=sda
	${MAKE} -C storage usb


sdb: info-cleaninstall commit
	export PARALLEL=1
	export TARGETDRIVE=sdb
	${MAKE} -C storage usb


sdc: info-cleaninstall commit 
	export PARALLEL=1
	export TARGETDRIVE=sdc
	${MAKE} -C storage usb

usb: info-cleaninstall commit
	export PARALLEL=1
	export TARGETDRIVE=$(TARGETDRIVE)
	${MAKE} -C storage usb


# make full automatic bootable iso (offline-) installer for current system,
# set env TARGET for other nix flake target systems
installer: info-iso-installer commit 
	@if [ !  -z  $(LUKS) ]; then (echo "LUKS Passwords for target installer-iso must explicitly set in autoinstall script, not in env." && exit 1);fi
	@export NIXPKGS_ALLOW_BROKEN=1 
	nix build --impure -L ".#nixosConfigurations.iso-installer.config.system.build.isoImage"
	ls -la /etc/nixos/result/iso

# XXX WIP: maybe currently broken
# make live iso image from current system, set env TARGET for other nix flake target systems
iso: info-cleaninstall commit
	nixos-rebuild build-image --flake $(OSFLAKE) --image-variant iso
	ls -la /etc/nixos/result/iso

# XXX WIP: maybe currently broken
# make live iso image from current system, set env TARGET for other nix flake target systems
qemu: info-cleaninstall commit
	nixos-rebuild build-image --flake $(OSFLAKE) --image-variant qemu-efi
	ls -la /etc/nixos/result/iso



#################
# LITTLE HELPER #
#################

sda-zero:
	${MAKE} -C storage sda-zero

sdb-zero:
	${MAKE} -C storage sdb-zero

sdc-zero:
	${MAKE} -C storage sdc-zero

trim:
	${MAKE} -C storage trim
zero: 
	${MAKE} -C storage zero

umount:  
	${MAKE} -C storage umount

wipe-home:
	$(SUDO) -v || exit 1
	$(SUDO) chown -R $(ID):$(GID) /home/$(NAME)
	cd || exit 1
	mv .local/share/atuin .
	mv .local/share/containers .
	rm -rf .cache .config .local .mozilla .librewolf .bash* .profile .sudo* .vim* .step .pki
	mkdir -p .cache .local/share .mozilla .librewolf 
	( cd .mozilla && ln -fs ../.librewolf firefox )
	mv atuin containers .local/share/
	$(SUDO) systemctl stop home-manager-me.service
	$(SUDO) systemctl start home-manager-me.service
