#!/usr/bin/make 
# add pkgs.gnumake to your nix base config!
.ONESHELL:

sdb:
	sudo nix run github:nix-community/disko/latest -- --mode destroy disko-lvm.nix
	sudo sync && sudo sync && sudo sync
	sudo nix run github:nix-community/disko/latest -- --mode format disko-lvm.nix
	sudo sync && sudo sync && sudo sync
	sudo pvdisplay
	sudo vgdisplay
	sudo lvdisplay

wipe-sdb:
	sudo dd if=/dev/zero of=/dev/sdb bs=512k oflag=direct status=progress count=128
