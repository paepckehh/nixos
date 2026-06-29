#!/bin/sh
rm -rf ~/.agents              > /dev/null 2>&1 
rm -rf ~/.config/crush/skills > /dev/null 2>&1 
rm -rf ~/.local/share/crush   > /dev/null 2>&1 
mkdir -p ~/.config/crush
mkdir -p ~/.local/share/crush
cp -af /etc/nixos/doc/crush/.agents ~/
cp -af /etc/nixos/doc/crush/skills ~/.config/crush/
cp -af /etc/nixos/doc/crush/crush.json ~/.local/share/crush/
