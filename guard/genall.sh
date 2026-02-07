#!/bin/sh
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
PSK=""
echo "PSK: Start genrating pre-shared keys!"
while ! [[ "$PSK" =~ ^[a-zA-Z0-9=]+$ ]]; do
        PSK=$(wg genpsk)
        echo "PSK: ... testing generated shared key: $PSK"
done
echo "PSK: Found valid PSK: $PSK"
echo "PK: Start genrate private keys!"
PUB=""
while ! [[ "$PUB" =~ ^[a-zA-Z0-9=]+$ ]]; do
 PK=""
 while ! [[ "$PK" =~ ^[a-zA-Z0-9=]+$ ]]; do
        PK=$(wg genpsk)
        echo "PK: ... testing generated PK: $PK"
 done
 echo "PK: Found valid PK: $PK"
 echo "PUB: Start genrate private keys!"
 PUB=$(echo $PK | wg pubkey)
 echo "PUB: ... testing Public Key: $PUB of Private Key: $PK"
done 
echo "PUB: Found valid PUB: $PUB"
echo "### DONE ###"
echo "FINAL: Found valid KeyTriple PSK: $PSK , PK: $PK , PUB: $PUB"
