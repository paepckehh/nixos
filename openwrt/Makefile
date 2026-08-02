#!/usr/bin/$(MAKE) 
.ONESHELL:
DTS:=$(shell date '+%Y-%m-%d-%H-%M')

all: update build

images: axt dap rpi2

update: axt-update dap-update rpi2-update

clean: axt-clean dap-clean rpi2-clean

clone:
	rm -rf nix-openwrt-imagebuilder
	git clone https://github.com/astro/nix-openwrt-imagebuilder

backup: axt-backup dap-backup rpi-backup b3000-backup


###################
# GL-INET-AXT1800 #
###################
axt: axt.luci

axt.update:
	$(MAKE) -C glinet/gl-axt1800 update

axt.clean:
	$(MAKE) -C glinet/gl-axt1800 clean

axt.config:
	ssh -p 6623 root@192.168.80.1 uci show | sed '/.key=/d'

axt.backup:
	mkdir -p /nix/persist/backup/openwrt/uci.conf/axt
	ssh -p 6623 root@192.168.80.1 "uci show | sed '/.key=/d'" > /nix/persist/backup/openwrt/uci.conf/axt/$(DTS).uci-config.txt
	ssh -p 6623 root@192.168.80.1 "uci show | grep '.key='" > /nix/persist/backup/openwrt/uci.conf/axt/$(DTS).uci-config.secret.txt

axt.btop:
	ssh -t -p 6623 root@192.168.80.1 "LANG=en_US.UTF-8 btop"

axt.ssh:
	ssh -p 6623 root@192.168.80.1

axt.stop:
	ssh -p 6623 root@192.168.80.1 "service uhttpd stop ; service rpcd stop"

axt.luci:
	xdg-open https://localhost:8099
	ssh -p 6623 root@192.168.80.1 "service rpcd start ; service uhttpd start"
	ssh -p 6623 -v -N -T -L localhost:8099:127.0.0.1:443 root@192.168.80.1

axt.dns:
	xdg-open http://localhost:8888
	ssh -p 6623 -v -N -T -L localhost:8888:127.0.0.1:8888 root@192.168.80.1

#################
# GL-INET-B3000 #
#################
b3000:
	$(MAKE) -C glinet/gl-b3000 image
	eza --all --long --total-size --group-directories-first --header --tree glinet/gl-b3000

b3000.update:
	$(MAKE) -C glinet/gl-axt1800 update

b3000.clean:
	$(MAKE) -C glinet/gl-axt1800 clean

b3000.config:
	ssh -p 6622 root@192.168.90.250 "uci show | sed '/.key=/d'"

b3000.backup:
	mkdir -p /etc/nixos/openwrt/config/b3000
	ssh -p 6622 root@192.168.90.250 "uci show | sed '/.key=/d'" > /etc/nixos/openwrt/config/b3000/$(DTS).uci-config

b3000.btop:
	ssh -t -p 6622 root@192.168.90.250 "LANG=en_US.UTF-8 btop"

b3000.luci:
	ssh -p 6622 root@192.168.90.250 "service uhttpd start"
	ssh -p 6622 -L 127.0.0.1:8443:127.0.0.1:8443 root@192.168.90.250


#####################
# RASPBERRY-PI RPI2 #
#####################
rpi2:
	$(MAKE) -C rpi/rpi2 image
	eza --all --long --total-size --group-directories-first --header --tree rpi/rpi2

rpi2.update:
	$(MAKE) -C rpi/rpi2 update

rpi2.clean:
	$(MAKE) -C rpi/rpi2 clean

rpi2.config:
	ssh -p 6623 root@rpi2.lan uci show | sed '/.key=/d'

rpi2.btop:
	ssh -t -p 6623 root@rpi2.lan "LANG=en_US.UTF-8 btop"

rpi2.backup:
	mkdir -p /etc/nixos/openwrt/config/rpi2
	ssh -p 6623 root@rpi2.lan "uci show | sed '/.key=/d'" > /etc/nixos/openwrt/config/rpi2/$(DTS).uci-config

rpi2.luci:
	ssh -p 6623 root@rpi2.lan "service uhttpd start"
	ssh -p 6623 -L localhost:8092:127.0.0.1:8080 root@rpi2.lan


######################
# DLINK DAP-X1860-A1 #
###################### 
dap:
	$(MAKE) -C dlink/dap-x1860-a1 image
	eza --all --long --total-size --group-directories-first --header --tree dlink/dap-x1860-a1

dap.update:
	$(MAKE) -C dlink/dap-x1860-a1 update

dap.clean:
	$(MAKE) -C dlink/dap-x1860-a1 clean

dap.config:
	ssh -p 6623 root@dap.lan uci show | sed '/.key=/d'

dap.btop:
	ssh -t -p 6623 root@dap.lan "LANG=en_US.UTF-8 btop"

dap.backup:
	mkdir -p /etc/nixos/openwrt/config/dap
	ssh -p 6623 root@dap.lan "uci show | sed '/.key=/d'" > /etc/nixos/openwrt/config/dap/$(DTS).uci-config

dap.luci:
	ssh -p 6623 root@dap.lan "service uhttpd start"
	ssh -p 6623 -L localhost:8094:127.0.0.1:8080 root@dap.lan 


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

