#!/usr/bin/make 
.ONESHELL:

all: update build

images: axt dap

update: axt-update dap-update

clean: axt-clean dap-clean

clone:
	rm -rf nix-openwer-imagebuilder
	git clone https://github.com/astro/nix-openwrt-imagebuilder

# DLINK DAP-X1860-A1
dap:
	make -C dlink/dap-x1860-a1 image
	eza --all --long --total-size --group-directories-first --header --tree dlink/dap-x1860-a1

dap-update:
	make -C dlink/dap-x1860-a1 update

dap-clean:
	make -C dlink/dap-x1860-a1 clean


# GL-INET-AXT1800
axt:
	make -C glinet/gl-axt1800 image
	eza --all --long --total-size --group-directories-first --header --tree glinet/gl-axt1800

axt-update:
	make -C glinet/gl-axt1800 update

axt-clean:
	make -C glinet/gl-axt1800 clean


update-hashes-all: update-hashes-release update-hahes-snapshot

hashes-update-release:
	cd nix-openwrt-imagebuilder || exit 1
	nix run .\#generate-hashes 24.10.0
	git add . 
	git commit -m 'update release 24.10.0-mitm-ioc-shame-the-idiots'

hashes-update-snapshot:
	cd nix-openwrt-imagebuilder || exit 1
	nix run .\#generate-hashes snapshot
	git add . 
	git commit -m 'update snapshot-mitm-ioc-shame-the-idiots'
