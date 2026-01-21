# PREP
BRAND?=debiguard
NETWORK?=10.20.66
TARGETDIR?=~/Downloads

###########
# GENERIC #
###########
all:
	@echo "make sda # => write generic preconfigured image to disk /dev/sda"
	@echo "make sdb # => write generic preconfigured image to disk /dev/sdb"
	@echo "ID=102 KEY=[wireguard-secret-key] make prep # write openwrt restore file into your home ~/Downloads."
	@echo "# ID is the ip address (last segment) and hostname identifier suffix"
	@echo "# KEY is the individual wireguard private key"

sda:
	@echo "Write & configure generic preconfigured image to disk /dev/sda ... "

sdb:
	@echo "Write & configure generic preconfigured image to disk /dev/sdb ... "

prep:
	@echo "Write openwrt restore file into home ~/Downloads."
ifeq ($(origin ID),undefined)
	@echo "env variable ID missing"
	exit 1
endif
ifeq ($(origin KEY),undefined)
	@echo "env variable KEY missing"
	exit 1
endif
	mkdir -p $(TARGETDIR) 
	rm -rf $(TARGETDIR)/etc > /dev/null 2>&1 || true 
	cp -af etc $(TARGETDIR)/
	sed -i 's/REPLACEHOSTNAME/$(BRAND)$(ID)/g' $(TARGETDIR)/etc/config/system 
	sed -i 's/REPLACEWGPKEY/$(BRAND)$(KEY)/g' $(TARGETDIR)/etc/config/network
	sed -i 's/REPLACEMYIP/$(NETWORK).$(ID)/g' $(TARGETDIR)/etc/config/network
	tar -cf $(TARGETDIR)/restore-me.tar $(TARGETDIR)/etc
	gzip $(TARGETDIR)/restore-me.tar
	rm -rf $(TARGETDIR)/etc > /dev/null 2>&1 || true 
