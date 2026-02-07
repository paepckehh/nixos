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
# kickInit /dev/urand with some added entroy
curl -vvvvvvvIk https://start 2>&1 | sudo tee -a /dev/urandom
dd if=/dev/urandom of=/dev/null bs=512k count=128 status=progress
counter=1
PSK=""
echo "PSK: Start pre-shared key-gen"
while ! [[ "$PSK" =~ ^[a-zA-Z0-9=]+$ ]]; do
        PSK=$(wg genpsk)
        # echo "PSK: ... testing generated shared key: $PSK"
done
# echo "PSK: Found valid PSK: $PSK"
# echo "PK: Start private key gen!"
PUB=""
while ! [ "$(echo -n $PUB | head -c 1)" == "d" ]; do
 PUB=""
 while ! [[ "$PUB" =~ ^[a-zA-Z0-9=]+$ ]]; do
  PK=""
  while ! [[ "$PK" =~ ^[a-zA-Z0-9=]+$ ]]; do
         PK=$(wg genpsk)
        ((counter++))
        echo -n '.'
        #  echo "PK: ... testing generated PK: $PK"
  done
  # echo "PK: Found valid PK: $PK"
  # echo "PUB: Start genrate private keys!"
  PUB=$(echo $PK | wg pubkey)
  # echo "PUB: ... testing Public Key: $PUB of Private Key: $PK"
 echo -n '#'
 done 
 # echo "PUB: Found valid PUB: $PUB"
echo -n "!"
done 
# echo "PUB: Found valid vanity PUB: $PUB"
echo
echo "FINAL: Found valid KeyTriple after $counter rounds => PSK: $PSK , PK: $PK , PUB: $PUB"
