#!/usr/bin/make

all: update image

image:
	nix build "#image"

update:
	nix flake update

clean:
	rm -rf result
