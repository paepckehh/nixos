# PREP
BRAND?=debiguard
NETWORK?=10.20.66
TARGETDIR?=~/Downloads

###########
# GENERIC #
###########
all:
	@echo "ID=100 make gen             # generate wg.conf/opnwrt.resore.gz set for one $(BRAND)100"
	@echo "ID=100 NEXT=100 make gen    # generate sets for $(BRAND)100 to $(BRAND)200"

gen:
	@echo "Write openwrt restore file and wg.config into $(TARGETDIR)"
	BRAND=$(BRAND) TARGETDIR=$(TARGETDIR) sh ./genall.sh
