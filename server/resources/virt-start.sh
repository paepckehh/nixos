#!/bin/sh 
sudo virsh net-start default
sudo virsh net-autostart default
sudo virsh net-info default
ip a 
