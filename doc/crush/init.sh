#!/bin/sh
set -x -e
cp -af /etc/nixos/doc/crush/.agents /etc/nixos/doc/crush/.crushrc ~/
if [ "$1" == "skills" ]; then
	mkdir -p /tmp/skills
	cd /tmp/skills || exit 1
	git clone --depth 1 https://github.com/anthropics/skills anthropics
	git clone --depth 1 https://github.com/samber/cc-skills-golang cc-skills-golang
	ls -la
	echo "pick && migrate skills ~/.agents/skill/ && rm -rf /tmp/skills"
fi
