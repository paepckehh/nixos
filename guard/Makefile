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
	@echo "ID=111" make genall

sda:
	@echo "Write & configure generic preconfigured image to disk /dev/sda ... "

sdb:
	@echo "Write & configure generic preconfigured image to disk /dev/sdb ... "

genall:
	@echo "Write openwrt restore file and wg.config into $(TARGETDIR)"
	sh ./genall.sh
