#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

######################
# SETUP ENV DEFAULTS #
######################
REPO?=https://github.com/paepckehh/nixos
TARGET?=$(shell hostname)
TARGETDRIVE?=sdb
PARALLEL?=0
DEVICE_MAIN:=$(TARGETDRIVE)
USELUKS:=YES
DISKOFLAKE:=disko/stateless-luks.nix
ifeq ($(origin LUKS),undefined)
      USELUKS:=NO
      DISKOFLAKE:=disko/stateless.nix
endif
OSFLAKE:=/etc/nixos/\#$(TARGET)
WIPEDRIVE?=/dev/null
PATH:=/run/current-system/sw/bin
SUDO:=/run/wrappers/bin/sudo
EXT4MOPT:=-o noatime,nodiratime,discard,commit=10,nobarrier,data=writeback,journal_async_commit
EXT4FOPT:=-E packed_meta_blocks=1

all:

####################
# USBDRIVE TARGETS #
####################

usb: info check wipe format pre-mount mount post-mount install bootproof migrate umount

####################
# USBDRIVE GENERIC #
####################

info: 
	echo build target drive: /dev/$(TARGETDRIVE), target os: $(TARGET), os-flake: $(OSFLAKE), luks: $(USELUKS), build repo: $(REPO), disko-flake: $(DISKOFLAKE), jobs: $(PARALLEL)
	@if [ $(USELUKS) = "YES" ]; then (echo "### LUKS MODE ENABLED, PLEASE ENSURE PROPER DISK/STORAGE LAYOUT IN TARGETOS FLAKE CONFIG!" && sleep 3) ; fi  

check: 
	@if [ ! -e /dev/$(TARGETDRIVE) ]; then (echo "TARGETDRIVE: /dev/$(TARGETDRIVE) does not exists, exit" ; exit 1); fi  

install:
	$(SUDO) nixos-install --verbose --max-jobs $(PARALLEL) --cores $(PARALLEL) --impure --no-root-password --root /mnt --flake $(OSFLAKE)
	$(SUDO) git clone $(REPO) /mnt/nix/persist/etc/nixos
	$(SUDO) chown -R me:me /mnt/nix/persist/etc/nixos

pre-mount: 
	$(SUDO) umount -f /mnt/home /mnt/var/lib /mnt/etc/nixos /mnt/etc/ssh /mnt/root/.ssh || true
	$(SUDO) umount -f /mnt/boot /mnt/nix || true
	$(SUDO) umount -f /mnt || true
	$(SUDO) cryptsetup close mnt-nix || true
	$(SUDO) cryptsetup close nix || true 

mount:
	$(SUDO) mkdir -p /mnt
	$(SUDO) mount -o rw,relatime,mode=755,huge=within_size -t tmpfs tmpfs /mnt
	$(SUDO) mkdir -p /mnt/boot /mnt/nix
	$(SUDO) mount /dev/$(TARGETDRIVE)1 /mnt/boot || exit 1
	if [ $(USELUKS) = "NO" ]; then
	   $(SUDO) mkfs.ext4 $(EXT4FOPT) /dev/$(TARGETDRIVE)3 || exit 1
	   $(SUDO) mount $(EXT4MOPT) /dev/$(TARGETDRIVE)3 /mnt/nix 
	fi
	if [ $(USELUKS) = "YES" ]; then 
	  $(SUDO) cryptsetup open /dev/$(TARGETDRIVE)3 mnt-nix < /tmp/luks || exit 1
	  $(SUDO) rm -rf /tmp/luks
	  $(SUDO) mkfs.ext4 $(EXT4FOPT) /dev/mapper/mnt-nix || exit 1
	  $(SUDO) mount $(EXT4MOPT) /dev/mapper/mnt-nix /mnt/nix || exit 1
	fi

post-mount:
	$(SUDO) mkdir -p /mnt/nix/persist/home /mnt/nix/persist/var/lib /mnt/nix/persist/etc/nixos /mnt/nix/persist/etc/ssh /mnt/nix/persist/root/.ssh
	$(SUDO) mkdir -p /mnt/home/me /mnt/var/lib /mnt/etc/nixos /mnt/etc/ssh /mnt/root/.ssh 
	$(SUDO) mount -o bind /mnt/nix/persist/home /mnt/home
	$(SUDO) mount -o bind /mnt/nix/persist/var/lib /mnt/var/lib
	$(SUDO) mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
	$(SUDO) mount -o bind /mnt/nix/persist/etc/ssh /mnt/etc/ssh
	$(SUDO) mount -o bind /mnt/nix/persist/root/.ssh /mnt/root/.ssh

bootproof: 
	$(SUDO) bootctl --no-pager --esp-path=/mnt/boot status || exit 1

umount:
	$(SUDO) sync && sync && sync
	$(SUDO) umount -f /mnt/home /mnt/var/lib /mnt/etc/nixos /mnt/etc/ssh /mnt/root/.ssh  || true
	$(SUDO) umount -f /mnt/boot /mnt/nix || true
	$(SUDO) umount -f /mnt || true
	$(SUDO) rm -rf /mnt /tmp/luks || true
	$(SUDO) cryptsetup close mnt-nix || true

format:
	echo ${LUKS} > /tmp/luks
	$(SUDO) nix run github:nix-community/disko/latest -- --mode format --argstr diskDevice /dev/$(TARGETDRIVE) $(DISKOFLAKE) || exit 1

wipe:
	$(SUDO) nix run github:nix-community/disko/latest -- --mode destroy --argstr diskDevice /dev/$(TARGETDRIVE) $(DISKOFLAKE) || exit 1
	ZERODRIVE=$(TARGETDRIVE) $(MAKE) trim 

###################
# MIGRATE SECRETS #
###################

migrate: migrate-etcssh migrate-root migrate-me migrate-backup migrate-projects migrate-me-master

migrate-etcssh:
	$(SUDO) mkdir -p /mnt/nix/persist/etc/ssh | true
	$(SUDO) cp -af /etc/ssh/ssh_host_ed25519* /mnt/nix/persist/etc/ssh/  | true
	$(SUDO) chmod 700 /mnt/nix/persist/etc/ssh/ssh_host_ed25519_key | true 
	$(SUDO) chmod 644 /mnt/nix/persist/etc/ssh/ssh_host_ed25519_key.pub | true 
	$(SUDO) chown -R 0:0 /mnt/nix/persist/etc/ssh | true

migrate-root:
	$(SUDO) cp -rf /root/.ssh /mnt/nix/persist/root/ | true
	$(SUDO) chmod 700 /mnt/nix/persist/root/.ssh | true
	$(SUDO) chmod 600 /mnt/nix/persist/root/.ssh/id_ed25519 | true 
	$(SUDO) chmod 644 /mnt/nix/persist/root/.ssh/id_ed25519.pub | true
	$(SUDO) chmod 644 /mnt/nix/persist/root/.ssh/known_hosts | true
	$(SUDO) chown -R 0:0 /mnt/nix/persist/root | true

migrate-me:
	$(SUDO) mkdir -p /mnt/nix/persist 
	$(SUDO) mkdir -p /mnt/nix/persist/home 
	$(SUDO) mkdir -p /mnt/nix/persist/home/me
	$(SUDO) cp -rf /home/me/.ssh /mnt/nix/persist/home/me/ | true
	$(SUDO) cp -rf /home/me/.local/share/atuin /mnt/nix/persist/home/me/.local/share/ | true
	$(SUDO) chmod 700 /mnt/nix/persist/home/me/.ssh | true
	$(SUDO) chmod 600 /mnt/nix/persist/home/me/.ssh/pwd.kdbx | true
	$(SUDO) chmod 600 /mnt/nix/persist/home/me/.ssh/id_ed25519 | true 
	$(SUDO) chmod 644 /mnt/nix/persist/home/me/.ssh/id_ed25519.pub | true
	$(SUDO) chmod 644 /mnt/nix/persist/home/me/.ssh/known_hosts | true

migrate-backup:
	$(SUDO) cp -rf /home/backup /mnt/nix/persist/home/ | true
	$(SUDO) chown -R me:me /mnt/nix/persist/home/backup | true

migrate-projects:
	$(SUDO) cp -rf /home/projects /mnt/nix/persist/home/ | true 
	$(SUDO) chown -R me:me /mnt/nix/persist/home/projects | true

migrate-me-master:
	$(SUDO) chown -R me:me /home/me | true
	$(SUDO) mkdir -p /mnt/nix/persist/home | true
	$(SUDO) chown -R me:me /mnt/nix/persist/home | true
	sync && sync



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
