#!/bin/sh
sudo -v
if ! [[ "$ID" =~ ^[0-9]+$ ]]; then
        echo "ID variable contains: $ID"
        echo "ID variable should contain a number only, below 250!"
        echo "The ID variable defines the last octed of the ip address and hostname appendinx."
        exit 1
fi
if ! [ $ID -lt 250 ]; then
        echo "ID variable contains: $ID"
        echo "ID variable should contain a number only, below 250!"
        echo "The ID variable defines the last octed of the ip address and hostname appendinx."
        exit 1
fi
if [ ! -x $(TARGETDIR) ]; then 
	echo "Unable to access $(TARGETDIR)"
	exit 1
fi
# kickInit /dev/urand with some added entroy
curl -vvvvvvvIk https://start 2>&1 | openssl enc -a  | openssl enc -a | sudo tee -a /dev/urandom
counter=1
while [ $counter -lt 1500 ] ; do 
PSK="" 
while ! [ "$(echo -n $PSK | cut -c 2)" == "c" ]; do 
 PSK=""
  while ! [[ "$PSK" =~ ^[a-zA-Z0-9=]+$ ]]; do
    PSK=$(wg genpsk) 
    ((counter++))
    echo -n '.'
  done
echo -n "!"
done 
PUB=""
 while ! [ "$(echo -n $PUB | cut -c 2)" == "c" ]; do
  PUB=""
  while ! [[ "$PUB" =~ ^[a-zA-Z0-9=]+$ ]]; do
   PK=""
   while ! [[ "$PK" =~ ^[a-zA-Z0-9=]+$ ]]; do
         PK=$(wg genpsk)
        ((counter++))
        echo -n '.'
   done
   PUB=$(echo $PK | wg pubkey)
   echo -n '#'
   done 
  echo -n "!"
 done
done 
echo
echo "FINAL: Found valid KeyTriple after $counter keys generated => PSK: $PSK , PK: $PK , PUB: $PUB"
