#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

# DEFAULTS
ID:=$(shell id -u)
GID:=$(shell id -g)
ISO?=iso
HOST?=$(shell hostname)
DTS:=$(shell date '+%Y-%m-%d-%H-%M')
FLAKE:="/etc/nixos/.\#$(HOST)"
PROFILE:="$(HOST)-$(DTS)"

###########
# GENERIC #
###########

all: update build

info:
	@echo "STATUS # $(MAKE) # ID: $(ID) # GID: $(GID) # HOST $(HOST) # DTS: $(DTS) # PROFILE: $(PROFILE) # FLAKE: $(FLAKE)"
	@echo "Set HOST='hostname' to build for a specific host target. Your current target HOST=$(HOST)."
	@echo "Set ISO='image-variant' to build a specific image type. Defaults to iso."
	sudo nixos-rebuild build-image --flake $(FLAKE)  || true

info-iso:
	@echo "Building for target HOST=$(HOST)"
	@echo -e "Your new nixos iso image profile ==> $(PROFILE) =======> \033[48;5;57m   $(PROFILE)   \033[0m <=========="

info-profile:
	@echo "Building for target HOST=$(HOST)"
	@echo -e "Your new nixos boot profile name ==> $(PROFILE) =======> \033[48;5;57m   $(PROFILE)   \033[0m <=========="


#####################
# NIX OS OPERATIONS #
#####################

build: info-profile commit build-log
	sudo nixos-rebuild boot --flake $(FLAKE) --profile-name $(PROFILE)

switch: info-profile commit build-log
	sudo nixos-rebuild switch --flake $(FLAKE) --profile-name $(PROFILE)

update: commit 
	mkdir -p .attic/flake.lock
	cp -f flake.lock .attic/flake.lock/$(date '+%Y-%m-%d--%H-%M').flake.lock
	nix flake update
        
bootloader:
	sudo nixos-rebuild boot -v --fallback --install-bootloader

iso: info-iso
	sudo nixos-rebuild build-image --flake $(FLAKE) --image-variant iso
	ls -la /etc/nixos/result/iso

iso-install: info-iso
	NIXPKGS_ALLOW_BROKEN=1 nix build --impure -L ".#nixosConfigurations.iso-installer.config.system.build.isoImage"
	ls -la /etc/nixos/result/iso

test: commit build-log
	sudo nixos-rebuild dry-activate --flake $(FLAKE)

offline:
	# XXX broken: fixme
	sudo nixos-rebuild boot -v --option use-binary-caches false --flake $(FLAKE) --profile-name $(PROFILE)
      
rollback: 
	# XXX broken: fixme
	sudo nixos-rebuild switch --rollback 

build-log:
	sudo nom build ".#nixosConfigurations.$(HOST).config.system.build.toplevel"
	@sudo rm -rf result


#######################
# NIX REPO OPERATIONS #
#######################

push: pre-commit 
	git add .
	git commit -S -m update
	git push --force 

commit: pre-commit
	git add .
	-git commit --quiet -m update > /dev/null 2>&1 || true

pre-commit:
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

gc: commit 
	git reflog expire --expire-unreachable=now --all 
	git gc --aggressive --prune=now 
	git fsck --full 


########################
# NIX STORE OPERATIONS #
########################

clean: build internal-clean-12d build store-gc

clean-hard: build internal-clean-profiles internal-clean-1d build store-gc

clean-profiles: build internal-clean-profiles build

cache: update build-nixos-all sign

build-nixos-all:
	nixos-rebuild build -v --fallback --flake "/etc/nixos/#nixos-all"
	rm -rf result

sign:
	sudo nix store sign --all --key-file /var/cache-priv-key.pem

store-gc: 
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
	sudo rm -rf /boot/loader/entries
	sudo rm -rf /nix/var/nix/profiles/system*
	sudo mkdir -p /boot/loader/entries 
	sudo chmod -R 700 /boot/loader/entries
	sudo mkdir -p /nix/var/nix/profiles/system-profiles
