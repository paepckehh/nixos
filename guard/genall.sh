#!/bin/sh
sudo -v
if ! [[ "$ID" =~ ^[0-9]+$ ]]; then
	echo "ID variable contains: $ID"
	echo "ID variable should contain a number only."
	echo "The ID/NEXT variables define the last octed of the ip address."
	exit 1
fi
if ! [ $ID -lt 250 ]; then
	echo "ID variable contains: $ID"
	echo "ID variable should contain a number below 250!"
	echo "The ID/NEXT variables define the last octed of the ip address."
	exit 1
fi
if [ -z $NEXT ]; then
	NEXT=1
fi
if ! [[ "$NEXT" =~ ^[0-9]+$ ]]; then
	echo "NEXT variable contains: $NEXT"
	echo "NEXT variable should contain a number only."
	echo "The ID/NEXT variable defines the last octed of the ip address."
	exit 1
fi
if [ "$(($NEXT + $ID))" -gt 250 ]; then
	echo "ID variable contains: $ID"
	echo "NEXT variable contains: $NEXT"
	echo "Adding NEXT and ID should stay below 250."
	echo "The ID/NEXT variable defines the last octed of the ip address."
	exit 1
fi
if [ ! -x $TARGETDIR ]; then
	echo "Unable to access $TARGETDIR"
	exit 1
fi

initUrand() {
	CKEY="$(echo "$(date +%N)$(date +%N)$(date)$(date +%N)$(date +%N)$(date)$(ps -aux)" | openssl sha3-512 | cut -c 18-81)"
	IV="$(echo "$(date)$(date +%N)$(date)$(date +%N)$(date +%N)$(ps -aux)" | openssl sha3-512 | cut -c 18-49)"
        STATE="$(sudo ps -aux)$(date)$(date +%N)$(date +%N)$(sudo dmesg)$(sudo ps -aux)$(date +%N)"
	TOKEN="$(echo $STATE | openssl enc -a | sed ':a;N;$!ba;s/\n//g' | openssl enc -chacha20 -K $CKEY -iv $IV | openssl enc -a | sed ':a;N;$!ba;s/\n//g')"
        FEED="$(echo $TOKEN | openssl sha3-256 | cut -c 18- | openssl enc -a | sed ':a;N;$!ba;s/\n//g')"
	echo "$FEED" | sudo tee -a /dev/urandom > /dev/null
        dd if=/dev/urandom of=/dev/null bs=64 count=1024 > /dev/null 2>&1 
        FEED="[...]$(echo $FEED | cut -c 64-)"
}

genKeyTriple() {
	counter=1
	while [ $counter -lt 800 ]; do
		PSK=""
		while ! [ "$(echo -n $PSK | cut -c 3)" == "c" ]; do
			PSK=""
			while ! [[ "$PSK" =~ ^[a-zA-Z0-9=]+$ ]]; do
				PSK=$(wg genpsk)
				counter=$((counter + 1))
				echo -n '.'
			done
			echo -n "$"
		done
		PUB=""
		while ! [ "$(echo -n $PUB | cut -c 3)" == "c" ]; do
			PUB=""
			while ! [[ "$PUB" =~ ^[a-zA-Z0-9=]+$ ]]; do
				PK=""
				while ! [[ "$PK" =~ ^[a-zA-Z0-9=]+$ ]]; do
					PK=$(wg genpsk)
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

# main loop
initUrand
echo $TOKEN
loop=0
ID=$((ID - 1))
while [ "$loop" -lt "$NEXT" ]; do
	loop=$((loop + 1))
	ID=$((ID + 1))
	echo
	initUrand
	echo "# INIT KEY TRIPLE GEN FOR CONFIG: ($TARGETDIR)<$BRAND$ID>, pushing uRandFeed $FEED"
	genKeyTriple
	echo
	echo "# VALID TRIPLE FOUND AFTER $counter ROUNDS => PSK: $PSK , PUB: $PUB, PK: [secret]"
	echo
	echo
done
