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
REPO:=/etc/nixos
OSFLAKE:=$(REPO)\#$(TARGET)
ISOFLAKE:=$(REPO)/.\#iso 
ALLFLAKE:=$(REPO)/.\#srv-full
PROFILE:="$(TARGET)-$(DTS)"
TYPE:="nixos boot profile"
USELUKS:=YES
MIRROR:=/home/projects/nixos
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
	alejandra --quiet .
	git add .

info-iso-installer:
	@echo "Building iso-auto-installer ..."
	
info-image:
	$(SUDO) nixos-rebuild build-image --flake $(OSFLAKE)  || true

####################
# NIXOS OPERATIONS #
####################
boot: build 
test: check
test-all: check
	  nix flake check 

build:  check   
	$(SUDO) nixos-rebuild boot --flake $(OSFLAKE) --profile-name $(PROFILE)

buildagain: check 
	$(SUDO) nixos-rebuild boot --flake $(OSFLAKE) --profile-name $(PROFILE)

recover: check 
	@echo "Recover Build for system /mnt and $(OSFLAKE)"
	$(SUDO) nixos-install --verbose --max-jobs $(PARALLEL) --cores $(PARALLEL) --keep-going --impure --no-root-password --root /mnt --flake $(OSFLAKE)

check: creds info
	alejandra --quiet .
	git add .
	nom build ".#nixosConfigurations.$(TARGET).config.system.build.toplevel"
	@$(SUDO) rm -rf result

wake-cache:
	$(SUDO) systemctl restart ncps.service || true
	$(SUDO) systemctl restart nix-daemon.service || true

switch: check 
	$(SUDO) nixos-rebuild switch --flake $(OSFLAKE) --profile-name $(PROFILE)

update: creds 
	mkdir -p .attic/flake.lock
	cp -f flake.lock .attic/flake.lock/$(DTS).flake.lock
	nix flake update

bootloader: check 
	$(SUDO) nixos-rebuild boot -v --fallback --install-bootloader

offline: check
	git add .
	$(SUDO) nixos-rebuild boot -v --flake $(OSFLAKE) --profile-name $(PROFILE)
      
rollback: check 
	$(SUDO) nixos-rebuild switch --rollback 


#######################
# NIX REPO OPERATIONS #
#######################
push: pre-commit 
	git add .
	git commit -S -m 'update'
	git push --force 

commit: pre-commit
	git add .
	-git commit -S --quiet -m 'update' > /dev/null 2>&1 || true

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
clean-profiles: internal-clean-profiles build buildagain 
	$(SUDO) ls -la /boot/loader/entries

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
TARGETDRIVE?=sdb

sda: info-cleaninstall
	export PARALLEL=1
	export TARGETDRIVE=sda
	${MAKE} -C storage usb


sdb: info-cleaninstall 
	export PARALLEL=1
	export TARGETDRIVE=sdb
	${MAKE} -C storage usb


sdc: info-cleaninstall  
	export PARALLEL=1
	export TARGETDRIVE=sdc
	${MAKE} -C storage usb

usb: info-cleaninstall
	export PARALLEL=1
	export TARGETDRIVE=$(TARGETDRIVE)
	${MAKE} -C storage usb


# make full automatic bootable iso (offline-) installer for current system,
# set env TARGET for other nix flake target systems
installer: info-iso-installer  
	@if [ !  -z  $(LUKS) ]; then (echo "LUKS Passwords for target installer-iso must explicitly set in autoinstall script, not in env." && exit 1);fi
	@export NIXPKGS_ALLOW_BROKEN=1 
	nix build --impure -L ".#nixosConfigurations.iso-installer.config.system.build.isoImage"
	ls -la /etc/nixos/result/iso

# XXX WIP: maybe currently broken
# make live iso image from current system, set env TARGET for other nix flake target systems
iso: info-cleaninstall 
	nixos-rebuild build-image --flake $(ISOFLAKE) --image-variant iso
	ls -la /etc/nixos/result/iso

# XXX WIP: maybe currently broken
# make live iso image from current system, set env TARGET for other nix flake target systems
qemu: info-cleaninstall 
	nixos-rebuild build-image --flake $(OSFLAKE) --image-variant qemu-efi
	ls -la /etc/nixos/result/iso

###########
# YUBIKEY #
###########
yubikey-generate-ssh:
	set +x
	echo "Please verify your PIN, Default Factory PIN: 123456"
	ykman fido info || exit 1
	ykman fido access verify-pin  || exit 1
	echo "Please change your PIN if it is still the factory one."
	echo "To keep your current PIN enter it 3x times."
	ykman fido access change-pin  || exit 1
	read -p "Enter your eMail Address: " EMAIL
	echo "Backup your complete ssh keystore state now to ~/.ssh.backup.$(DTS)"
	mkdir -p ~/.ssh || exit 1 
	cp -af ~/.ssh ~/.ssh.backup.$(DTS) || exit 1 
	rm -rf ~/.ssh/id_ed25519_sk ~/.ssh/id_ed25519_sk.pub > /dev/null 2>&1 || true 
	ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk <<< y

##############
# GIT MIRROR #
##############
mirror-update:
	$(SUDO) -v 
	git -C $(MIRROR)/agenix.git fetch
	git -C $(MIRROR)/disko.git fetch
	git -C $(MIRROR)/home-manager.git fetch
	git -C $(MIRROR)/nixpkgs.git fetch

mirror-compact:
	$(SUDO) -v 
	git -C $(REPO) gc --aggressive 
	git -C $(MIRROR)/agenix.git gc --aggressive 
	git -C $(MIRROR)/disko.git gc --aggressive
	git -C $(MIRROR)/home-manager.git gc --aggressive --keep-largest-pack
	git -C $(MIRROR)/nixpkgs.git gc --aggressive --keep-largest-pack

mirror-compact-full:
	$(SUDO) -v 
	git -C $(MIRROR)/agenix.git gc --aggressive
	git -C $(MIRROR)/disko.git gc --aggressive
	git -C $(MIRROR)/home-manager.git gc --aggressive 
	git -C $(MIRROR)/nixpkgs.git gc --aggressive 

#################
# LITTLE HELPER #
#################
nvme0-zero:
	${MAKE} -C storage nvme0-zero

nvme0-show:
	$(SUDO) lsblk -td
	$(SUDO) nvme id-ns -H /dev/nvme0n1 
	$(SUDO) nvme id-ctrl /dev/nvme0n1 
	$(SUDO) smartctl -c /dev/nvme0n1

nvme0-lba-on:
	$(SUDO) nvme format /dev/nvme0n1 --lbaf=0 --ses=1 --reset --force --verbose
	$(SUDO) nvme format /dev/nvme0n1 --lbaf=1 --reset --force --verbose

nvme0-lba-off:
	$(SUDO) nvme format /dev/nvme0n1 --lbaf=1 --ses=1 --reset --force --verbose
	$(SUDO) nvme format /dev/nvme0n1 --lbaf=0 --reset --force --verbose

nvme0-luks-list:
	$(SUDO) cryptsetup luksDump /dev/nvme0s3

nvme0-luks-change-pwd:
	$(SUDO) cryptsetup luksChangeKey /dev/nvme0s3

nvme1-zero:
	${MAKE} -C storage nvme1-zero

nvme1-show:
	$(SUDO) lsblk -td
	$(SUDO) nvme id-ns -H /dev/nvme0n1 
	$(SUDO) nvme id-ctrl /dev/nvme0n1 
	$(SUDO) smartctl -c /dev/nvme0n1

nvme1-lba-on:
	$(SUDO) nvme format /dev/nvme0n1 --lbaf=0 --ses=1 --reset --force --verbose
	$(SUDO) nvme format /dev/nvme0n1 --lbaf=1 --reset --force --verbose

nvme1-lba-off:
	$(SUDO) nvme format /dev/nvme0n1 --lbaf=1 --ses=1 --reset --force --verbose
	$(SUDO) nvme format /dev/nvme0n1 --lbaf=0 --reset --force --verbose

nvme1-luks-list:
	$(SUDO) cryptsetup luksDump /dev/nvme1s3

nvme1-luks-change-pwd:
	$(SUDO) cryptsetup luksChangeKey /dev/nvme1s3

creds :
	$(SUDO) -v || exit 1
trim:
	${MAKE} -C storage trim
zero: 
	${MAKE} -C storage zero

umount:  
	${MAKE} -C storage umount

sda-zero:
	${MAKE} -C storage sda-zero

sdb-zero:
	${MAKE} -C storage sdb-zero

sdc-zero:
	${MAKE} -C storage sdc-zero

sda-luks-list:
	$(SUDO) cryptsetup luksDump /dev/sda3

sda-luks-change-pwd:
	$(SUDO) cryptsetup luksChangeKey /dev/sda3

sdb-luks-list:
	$(SUDO) cryptsetup luksDump /dev/sda3

sdb-luks-change-pwd:
	$(SUDO) cryptsetup luksChangeKey /dev/sda3

wipe-home:
	${MAKE} -C storage wipe-home 
