#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

# TOOLCHAIN 
BINPATH:=/run/current-system/sw/bin
BLKDISCARD:=$(BINPATH)/blkdiscard
CHOWN:=$(BINPATH)/chown
DATE:=$(BINPATH)/date
DD:=$(BINPATH)/dd
ECHO:=$(BINPATH)/echo
GIT:=$(BINPATH)/git
HOSTNAME:=$(BINPATH)/hostname
IDBIN:=$(BINPATH)/id
LS:=$(BINPATH)/ls
MAKE=$(BINPATH)/make
MKDIR:=$(BINPATH)/mkdir
MOUNT:=$(BINPATH)/mount
MV:=$(BINPATH)/mv
NIX:=$(BINPATH)/nix
NIX-COLLECT-GARBAGE:=$(BINPATH)/nix-collect-garbage
NIX-ENV:=$(BINPATH)/nix-env
NIXFMT:=$(BINPATH)/alejandra
NIXOS-INSTALL:=$(BINPATH)/nixos-install
NIXOS-REBUILD:=$(BINPATH)/nixos-rebuild
NIX-STORE:=$(BINPATH)/nix-store
NOM:=$(BINPATH)/nom
NVME:=$(BINPATH)/nvme
RM:=$(BINPATH)/rm
SUDO:=$(BINPATH)/sudo 
SYSTEMCTL:=$(BINPATH)/systemctl
UMOUNT:=$(BINPATH)/umount

# DEFAULTS
ID:=$(shell $(IDBIN) -u)
GID:=$(shell $(IDBIN) -g)
ISO?=iso
TARGET?=$(shell $(HOSTNAME))
DTS:=$(shell $(DATE) '+%Y-%m-%d-%H-%M')
OSFLAKE:=/etc/nixos/\#$(TARGET)
ALLFLAKE:=/etc/nixos/.\#nixos-all
PROFILE:="$(TARGET)-$(DTS)"
TYPE:="nixos boot profile"
USELUKS:=YES
ifeq ($(origin LUKS),undefined)
      USELUKS:=NO
endif


###########
# GENERIC #
###########

all:
	@$(ECHO) "STATUS # $(MAKE) # ID: $(ID) # GID: $(GID) # TARGET: $(TARGET) # LUKS: $(USELUKS) # DTS: $(DTS) # PROFILE: $(PROFILE) # OSFLAKE: $(OSFLAKE)"
	@$(ECHO) "Set TARGET='hostname' to build for a specific host target. Your current target TARGET=$(TARGET)."
	@$(ECHO) "Set ISO='<image-variant>' to build a specific image type. Defaults to 'iso'. Run: make info-image to see all formats."
	@$(ECHO) "Set TARGETDISK='sdb' to build live-os on a specific target disk." 
	@$(ECHO) "Set LUKS='<secret>' to enable hardened luks fde during new disk build."

info:
	@$(ECHO) "Building for target TARGET=$(TARGET)"
	@$(ECHO) -e "Your new $(TYPE) ==> $(PROFILE) =======> \033[48;5;57m   $(PROFILE)   \033[0m <=========="

info-cleaninstall:
	@$(ECHO) "Building for target TARGET=$(TARGET) # Building on TARGETDRIVE=$(TARGETDRIVE) # Using LUKS: $(USELUKS) # OSFLAKE: $(OSFLAKE)"

info-iso-installer:
	@$(ECHO) "Building iso-auto-installer ..."
	
info-image:
	$(SUDO) $(NIXOS-REBUILD) build-image --flake $(OSFLAKE)  || true

####################
# NIXOS OPERATIONS #
####################

boot:   build 

build:  info commit build-log
	$(SUDO) $(NIXOS-REBUILD) boot --flake $(OSFLAKE) --profile-name $(PROFILE)

check: info
	$(SUDO) $(NIX) flake check 
	$(SUDO) $(NIXFMT) --quiet .

switch: info commit build-log
	$(SUDO) $(NIXOS-REBUILD) switch --flake $(OSFLAKE) --profile-name $(PROFILE)

update: commit  
	$(MKDIR) -p .attic/flake.lock
	$(CP) -f flake.lock .attic/flake.lock/$(DTS).flake.lock
	$(NIX) flake update
        
bootloader: info commit 
	$(SUDO) $(NIXOS-REBUILD) boot -v --fallback --install-bootloader

test: commit build-log
	$(SUDO) $(NIXOS-REBUILD) dry-activate --flake $(OSFLAKE)

offline: info commit 
	# XXX broken: fixme 
	$(SUDO) $(NIXOS-REBUILD) boot -v --flake $(OSFLAKE) --profile-name $(PROFILE)
      
rollback: commit
	# XXX broken: fixme 
	$(SUDO) $(NIXOS-REBUILD) switch --rollback 

build-log:
	$(SUDO) $(NOM) build ".#nixosConfigurations.$(TARGET).config.system.build.toplevel"
	@$(SUDO) $(RM) -rf result

#################
# NIXOS INSTALL #
#################

# install optimized usbdrive live os
# set env TARGETOS for other target-os, default: current-system [$hostname]
# set TARGETDRIVE for usb stick, default: sdb [uses: /dev/sdb] [supports: sda, sdb and sdc]
TARGETDRIVE?=sdb

sda: info-cleaninstall commit
	export TARGETDRIVE=sda
	$(MAKE) -C storage usb


sdb: info-cleaninstall commit
	export TARGETDRIVE=sdb
	$(MAKE) -C storage usb


sdc: info-cleaninstall commit 
	export TARGETDRIVE=sdc
	$(MAKE) -C storage usb

usb: info-cleaninstall commit
	export TARGETDRIVE=$(TARGETDRIVE)
	$(MAKE) -C storage usb


# make full automatic bootable iso (offline-) installer for current system,
# set env TARGET for other nix flake target systems
installer: info-iso-installer commit 
	@if [ !  -z  $(LUKS) ]; then ($(ECHO) "LUKS Passwords for target installer-iso must explicitly set in autoinstall script, not in env." && exit 1);fi
	@export NIXPKGS_ALLOW_BROKEN=1 
	$(NIX) build --impure -L ".#nixosConfigurations.iso-installer.config.system.build.isoImage"
	$(LS) -la /etc/nixos/result/iso

# XXX WIP: maybe currently broken
# make live iso image from current system, set env TARGET for other nix flake target systems
iso: info-cleaninstall commit
	$(SUDO) $(NIXOS-REBUILD) build-image --flake $(OSFLAKE) --image-variant iso
	$(LS) -la /etc/nixos/result/iso

# XXX WIP: maybe currently broken
# make live iso image from current system, set env TARGET for other nix flake target systems
qemu: info-cleaninstall commit
	$(SUDO) $(NIXOS-REBUILD) build-image --flake $(OSFLAKE) --image-variant qemu-efi
	$(LS) -la /etc/nixos/result/iso


#######################
# NIX REPO OPERATIONS #
#######################

push: pre-commit 
	$(GIT) add .
	$(GIT) commit -S -m update
	$(GIT) push --force 

commit: pre-commit
	$(GIT) add .
	-$(GIT) commit --quiet -m 'update' > /dev/null 2>&1 || true

pre-commit:
	@-$(SUDO) $(RM) -rf result > /dev/null 2>&1 || true
	@$(SUDO) $(CHOWN) -R $(ID):$(GID) *
	@$(SUDO) $(CHOWN) -R $(ID):$(GID) .git 
	@$(NIXFMT) --quiet .

followremote: 
	@$(GIT) reset --hard
	@$(GIT) clean --force 
	@$(GIT) checkout --force .
	@$(GIT) config pull.ff only
	$(GIT) pull --ff --force 
	@$(GIT)-gc

git-gc: commit 
	$(GIT) reflog expire --expire-unreachable=now --all 
	$(GIT) gc --aggressive --prune=now 
	$(GIT) fsck --full 


########################
# NIX STORE OPERATIONS #
########################

clean: internal-clean-12d build gc 

clean-hard: internal-clean-profiles internal-clean-1d build gc

clean-profiles: internal-clean-profiles build

cache: update build-nixos-all sign

build-nixos-all:
	$(NIXOS-REBUILD) build -v --fallback --flake $(ALLFLAKE)
	$(LS) -rf result

sign:
	$(SUDO) $(NIX) store sign --all --key-file /var/cache-priv-key.pem

gc: git-gc 
	$(SUDO) $(NIX-STORE) --gc
	$(SUDO) $(NIX-STORE) --optimise

repair: store-gc
	$(SUDO) $(NIX-STORE) --verify --check-contents --repair

internal-clean-1d:
	$(SUDO) $(NIX-ENV) --delete-generations --profile /nix/var/nix/profiles/system 1d
	$(SUDO) $(NIX-COLLECT-GARBAGE) --delete-older-than 1d

internal-clean-12d: 
	$(SUDO) $(NIX-ENV) --delete-generations --profile /nix/var/nix/profiles/system 12d
	$(SUDO) $(NIX-COLLECT-GARBAGE) --delete-older-than 12d 

internal-clean-profiles:
	$(SUDO) $(RM) -rf /boot/loader/entries || true
	$(SUDO) $(RM) -rf /nix/var/log/nix || true
	$(SUDO) $(RM) -rf /nix/var/nix/profiles/system* || true
	$(SUDO) $(RM) -p /boot/loader/entries 
	$(SUDO) $(CHMOD) -R 700 /boot/loader/entries
	$(SUDO) $(MKDIR) -p /nix/var/log/nix/drvs
	$(SUDO) $(MKDIR) -p /nix/var/nix/profiles/system-profiles


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
	cd || exit 1
	$(MV) .local/share/atuin .
	$(RM) -rf .local .cache .mozilla .librewolf
	$(MKDIR) -p .local/share
	$(MV) atuin .local/share/
	$(SUDO) -v || exit 1
	$(SUDO) $(SYSTEMCTL) stop home-manager-me.service
	$(SUDO) $(SYSTEMCTL) start home-manager-me.service
