#!/bin/sh
set -e
init_urand() {
	CKEY="$(echo "$(date +%N)$(date +%N)$(date)$(date +%N)$(date +%N)$(date)$(ps -aux)" | openssl sha3-512 | cut -c 18-81)"
	IV="$(echo "$(date)$(date +%N)$(date)$(date +%N)$(date +%N)$(ps -aux)" | openssl sha3-512 | cut -c 18-49)"
	STATE="$(ps -aux)$(date)$(date +%N)$(date +%N)$(ps -aux)$(date +%N)"
	TOKEN="$(echo $STATE | openssl enc -a | sed ':a;N;$!ba;s/\n//g' | openssl enc -e -chacha20 -K $CKEY -iv $IV | openssl enc -a | sed ':a;N;$!ba;s/\n//g')"
	FEED="$(echo $TOKEN | openssl sha3-256 | cut -c 18- | openssl enc -a | sed ':a;N;$!ba;s/\n//g')"
	echo "$FEED" | tee -a /dev/urandom >/dev/null
	dd if=/dev/urandom of=/dev/null bs=64 count=1024 >/dev/null 2>&1
	FEED="[...]$(echo $FEED | cut -c 64-)"
	echo "RND Feed: $FEED"
}

gen_key_triple() {
	counter=1
	while [ $counter -lt 800 ]; do
		PSK=""
		while ! [ "$(echo -n $PSK | cut -c 3)" == "$VKEY" ]; do
			PSK=""
			while ! [[ "$PSK" =~ ^[a-zA-Z0-9=]+$ ]]; do
				PSK=$(wg genpsk)
				counter=$((counter + 1))
				echo -n '.'
			done
			echo -n "$"
		done
		PUB=""
		while ! [ "$(echo -n $PUB | cut -c 3)" == "$VKEY" ]; do
			PUB=""
			while ! [[ "$PUB" =~ ^[a-zA-Z0-9=]+$ ]]; do
				PK=""
				while ! [[ "$PK" =~ ^[a-zA-Z0-9=]+$ ]]; do
					PK=$(wg genkey)
					counter=$((counter + 1))
					echo -n '.'
				done
				PUB=$(echo $PK | wg pubkey)
				echo -n '#'
			done
			echo -n "!"
		done
	done
}

init_store() {
	mkdir -p $WORKDIR
	sudo mount -t tmpfs tmpfs $WORKDIR
	sudo chmod 770 $WORKDIR
	sudo chown -R me:0 $WORKDIR
	echo "done $WORKDIR create"
	echo "non-persistent, clean keystore: $WORKDIR"
}

keyset_info() {
	echo
	echo "PK:  <secret>"
	echo "PUB: $PUB"
	echo "PSK: <secret>"
}

keyset_write() {
	echo "Write KeySET tripe with VKEY=$VKEY for $NAME to $WORKDIR"
	echo -n $PK >$WORKDIR/$NAME.pk
	echo -n $PSK >$WORKDIR/$NAME.psk
	echo -n $PUB >$WORKDIR/$NAME.pub
	sudo chmod 770 $WORKDIR
	sudo chmod 660 $WORKDIR/*
	sudo chown -R me:0 $WORKDIR
	echo && echo
}

init_parse() {
	echo && echo "init keygen.sh"
	if [ "$WORKDIR" == "" ]; then echo "keygen.sh: please specify workdir as first shell parameter" && exit 1; fi
	if [ "$NAME" == "" ]; then echo "keygen.sh: please specify name as second shell parameter" && exit 1; fi
	if [ "$VKEY" == "" ]; then echo "keygen.sh: please vkey as third shell parameter" && exit 1; fi
	if [ "$(echo -n $VKEY | wc --chars)" != "1" ]; then echo "keygen.sh: please vkey single character parameter" && exit 1; fi
}

# main
sudo -v || exit 1
WORKDIR=$1
NAME=$2
VKEY=$3
init_parse
init_store
init_urand
gen_key_triple
keyset_info
keyset_write
