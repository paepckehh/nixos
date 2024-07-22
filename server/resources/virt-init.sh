#!/bin/sh 
sudo virsh net-define ./default.xml
sh ./virt-start.sh
