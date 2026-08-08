#!/bin/sh
set -x -e
mkdir -p ~/.agents/skills ~/.config
cp -af /etc/nixos/doc/crush/.crushrc ~/
cp -af /etc/nixos/doc/crush/AGENTS.md ~/.config/AGENTS.md
if [ "$1" == "skills" ]; then
	mkdir -p /tmp/skills
	cd /tmp/skills || exit 1
	git clone --depth 1 https://github.com/anthropics/skills anthropics
	git clone --depth 1 https://github.com/samber/cc-skills-golang cc-skills-golang
	ls -la
	echo "pick && migrate skills ~/.agents/skill/ && rm -rf /tmp/skills"
fi
