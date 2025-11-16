#!/bin/sh
cd /home/project/nixos/nixos_nixpkgs || exit 1
git config core.sharedRepository true || exit 1
git config gc.auto 500 true || exit 1
git config remote.origin.url = https://github.com/nixos/nixpkgs || exit 1 
