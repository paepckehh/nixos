#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

#########
# SETUP #
######### 
BRAND?=homiguard
NETWORK?=10.20.66
PREFIX=RestoreME
TARGETDIR?=~/Downloads
PATH:=/run/current-system/sw/bin
SUDO:=/run/wrappers/bin/sudo
DTS:=$(shell date '+%Y-%m-%d-%H-%M')
TARBALL=$(PREFIX)-$(BRAND)$(ID)-$(DTS).tar
OUTFILE=$(TARBALL).gz
IMAGE?=secure.img.xz
TARGET?=sda
INSTANCE=turbo
DTS:=$(shell date '+%Y-%m-%d-%H-%M')
WIFI?=0

###########
# GENERIC #
###########
all:
	@echo "make sdcard # => write generic preconfigured image to disk /dev/sda"
	@echo "TARGET=sdb make sdcard # => write generic preconfigured image to disk /dev/sdb"
	@echo "ID='102' WPK='<pkey>' PSK='<psk>' make config # generate $(BRAND) restore config file: ~/Downloads/...."
	@echo "ID='100' make gen # generate one $(BRAND) restore config file: ~/Downloads/...."
	@echo "ID='100' NEXT=10 make gen # generate ten $(BRAND) restore config file: ~/Downloads/...."
	@echo "# ID is the ip address (last segment) and hostname identifier suffix"
	@echo "# Add WIFI=1 to keep Wifi and GUI enabled."

config:
ifeq ($(origin ID),undefined)
	@echo "env variable ID missing"
	exit 1
endif
ifeq ($(origin WPK),undefined)
	@echo "env variable WPK missing"
	exit 1
endif
ifeq ($(origin PSK),undefined)
	@echo "env variable PSK missing"
	exit 1
endif
	@echo "Write $(BRAND) restore file into home ~/Downloads."
	mkdir -p $(TARGETDIR) 
	rm -rf $(TARGETDIR)/etc > /dev/null 2>&1 || true 
	cp -af etc $(TARGETDIR)/
	cd $(TARGETDIR) || exit 1 
	sync && sync && sync
	sed -i 's/REPLACEHOSTNAME/$(BRAND)$(ID)/g' etc/config/system 
	sed -i 's/REPLACEWPK/$(WPK)/g'             etc/config/network
	sed -i 's/REPLACEPSK/$(PSK)/g'             etc/config/network
	sed -i 's/REPLACEIP/$(NETWORK).$(ID)/g'    etc/config/network
	rm -rf $(TARBALL) > /dev/null 2>&1 || true 
	rm -rf $(OUTFILE) > /dev/null 2>&1 || true 
	tar -cf $(TARBALL) etc
	gzip $(TARBALL)
	rm -rf etc 
	@echo "$(BRAND) restore-file: $(OUTFILE) generation done!"
	@echo "##################################"
	@echo "#### RESTORE CONFIG FINISHED! ####"
	@echo "##################################"
	ls -la 

gen:
	@echo "Write openwrt restore file and wireguard server csv config into $(TARGETDIR)"
	PREFIX=$(PREFIX) WIFI=$(WIFI) TARBALL=$(TARBALL) OUTFILE=$(OUTFILE) NETWORK=$(NETWORK) INSTANCE=$(INSTANCE) DTS=$(DTS) BRAND=$(BRAND) TARGETDIR=$(TARGETDIR) sh ./genall.sh

##############
# BASE IMAGE #
##############
sdcard:
	$(SUDO) -v
ifeq ($(origin TARGET),undefined)
	@echo "env variable TARGET missing"
	exit 1
endif
	@echo "Write & configure generic preconfigured image to disk /dev/$(TARGET)"
	@echo "*** DISK WIPE /dev/$(TARGET) starts in 5 Seconds!"
	@echo "*** You have 5 Seconds to cancel!"
	sync && sync && sync
	sleep 6
	$(SUDO) umount -f /run/media/me/boot > /dev/null 2>&1 || true
	$(SUDO) umount -f /run/media/me/rootfs > /dev/null 2>&1 || true
	$(SUDO) umount -f /dev/$(TARGET)1 > /dev/null 2>&1 || true
	$(SUDO) umount -f /dev/$(TARGET)2 > /dev/null 2>&1 || true
	sync && sync && sync
	@echo "Zero-Wipe disk /dev/$(TARGET) ... "
	$(SUDO) dd if=/dev/zero of=/dev/$(TARGET) oflag=sync bs=512k status=progress count=2048
	cat $(IMAGE) | unxz -c | $(SUDO) dd of=/dev/$(TARGET) oflag=sync bs=512k status=progress
	@echo "Write Image to disk /dev/$(TARGET) ..."
	sync && sync && sync && sleep 3
	until [ -x /run/media/me/boot ]
	do
		@echo "####################################"
		@echo "# UNPLUG AN RE-PLUG USB DRIVE NOW !#"
		@echo "####################################"
		sleep 5
	done
	echo "... drive found!"
	if [ "$(WIFI)" == "1" ]; then 
		$(SUDO) cp -af config-wifi.txt /run/media/me/boot/config.txt
	else 
		$(SUDO) cp -af config.txt /run/media/me/boot/config.txt
	fi
	sync && sync && sync
	$(SUDO) umount -f /run/media/me/rootfs > /dev/null 2>&1 || true
	$(SUDO) umount -f /run/media/me/boot > /dev/null 2>&1 || true
	$(SUDO) umount -f /dev/$(TARGET)1 > /dev/null 2>&1 || true
	$(SUDO) umount -f /dev/$(TARGET)2 > /dev/null 2>&1 || true
	sync && sync && sync
	@echo "########################################"
	@echo "#### $(BRAND) BASE IMAGE FINISHED!"
	@echo "########################################"

