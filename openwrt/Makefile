#!/usr/bin/$(MAKE) 
.ONESHELL:

all: update build

images: axt dap rpi2

update: axt-update dap-update rpi2-update

clean: axt-clean dap-clean rpi2-clean

clone:
	rm -rf nix-openwrt-imagebuilder
	git clone https://github.com/astro/nix-openwrt-imagebuilder

######################
# DLINK DAP-X1860-A1 #
###################### 
dap:
	$(MAKE) -C dlink/dap-x1860-a1 image
	eza --all --long --total-size --group-directories-first --header --tree dlink/dap-x1860-a1

dap-update:
	$(MAKE) -C dlink/dap-x1860-a1 update

dap-clean:
	$(MAKE) -C dlink/dap-x1860-a1 clean

###################
# GL-INET-AXT1800 #
###################
axt:
	$(MAKE) -C glinet/gl-axt1800 image
	eza --all --long --total-size --group-directories-first --header --tree glinet/gl-axt1800

axt-update:
	$(MAKE) -C glinet/gl-axt1800 update

axt-clean:
	$(MAKE) -C glinet/gl-axt1800 clean

#################
# GL-INET-B3000 #
#################
b3000:
	$(MAKE) -C glinet/gl-b3000 image
	eza --all --long --total-size --group-directories-first --header --tree glinet/gl-b3000

b3000-update:
	$(MAKE) -C glinet/gl-axt1800 update

b3000-clean:
	$(MAKE) -C glinet/gl-axt1800 clean

#####################
# RASPBERRY-PI RPI2 #
#####################
rpi2:
	$(MAKE) -C rpi/rpi2 image
	eza --all --long --total-size --group-directories-first --header --tree rpi/rpi2

rpi2-update:
	$(MAKE) -C rpi/rpi2 update

rpi2-clean:
	$(MAKE) -C rpi/rpi2 clean

######################
# LOCAL HASH UPDATES #
######################
update-hashes-all: update-hashes-release update-hahes-snapshot

hashes-update-release:
	cd nix-openwrt-imagebuilder || exit 1
	nix run .\#generate-hashes 24.10.0
	git add . 
	git commit -m 'update release 24.10.0-ioc-to-shame-the-clowns-pointless-mitm-theatre'

hashes-update-snapshot:
	cd nix-openwrt-imagebuilder || exit 1
	nix run .\#generate-hashes snapshot
	git add . 
	git commit -m 'update snapshot-ioc-to-shame-the-clowns-pointless-mitm-theatre'
