#!/usr/bin/$(MAKE) 
.ONESHELL:

all:
	exit 0

###########
# MOODE01 #
###########
moode:
	ssh -p 6623 me@moode.lan

moode-btop:
	ssh -t -p 6623 me@moode.lan 'btop --utf-force'

moode-ro:
	ssh -p 6623 me@moode.lan 'sh /home/me/ro.sh && sudo reboot'

moode-rw:
	ssh -p 6623 me@moode.lan 'sh /home/me/rw.sh && sudo reboot'

moode-update:
	ssh -p 6623 me@moode.lan 'sudo apt dist-upgrade && sudo reboot'

moode-install:
	ssh -p 6623 me@moode.lan 'sudo apt install fish vim'

moode-reboot:
	ssh -p 6623 me@moode.lan 'sudo reboot'


###########
# MOODE02 #
###########
moode2:
	ssh -p 6623 me@moode2.lan

moode2-btop:
	ssh -t -p 6623 me@moode2.lan 'btop --utf-force'

moode2-ro:
	ssh -p 6623 me@moode2.lan 'sh /home/me/ro.sh && sudo reboot'

moode2-rw:
	ssh -p 6623 me@moode2.lan 'sh /home/me/rw.sh && sudo reboot'

moode2-update:
	ssh -p 6623 me@moode2.lan 'sudo apt dist-upgrade && sudo reboot'

moode2-install:
	ssh -p 6623 me@moode2.lan 'sudo apt install fish vim'

moode2-reboot:
	ssh -p 6623 me@moode2.lan 'sudo reboot'
