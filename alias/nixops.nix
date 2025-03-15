{config, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "nix.sign" = ''
        cd /etc/nixos &&\
        cd /nix/store &&\
        env sudo -v &&\
        sudo nix store sign --all --key-file /var/cache-priv-key.pem '';
      "nix.push" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo alejandra --quiet . &&\
        sudo chown -R me:users .git &&\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        git reflog expire --expire-unreachable=now --all ;\
        git gc --aggressive --prune=now ;\
        git fsck --full ;\
        git push --force '';
      "nix.repair" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo nix-store --gc ;\
        sudo nix-store --verify --check-contents --repair'';
      "nix.clean" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 12d ;\
        sudo nix-collect-garbage --delete-older-than 12d ;\
        sudo nix-store --gc ;\
        sudo nix-store --optimise'';
      "nix.clean.profiles" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo rm /boot/loader/entries ;\
        sudo rm -rf /nix/var/nix/profiles/system* ;\
        sudo mkdir -p /boot/loader/entries ;\
        sudo chmod -R 700 /boot/loader/entries ;\
        sudo mkdir -p /nix/var/nix/profiles/system-profiles ;\
        nix.build'';
      "nix.hardclean" = ''
        nix.clean.profiles
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 1d ;\
        sudo nix-collect-garbage --delete-older-than 1d ;\
        sudo nix-store --gc ;\
        sudo nix-store --optimise '';
      "nix.test" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo alejandra --quiet . ;\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        sudo nixos-rebuild dry-activate --flake /etc/nixos/.#$(hostname)'';
      "nix.followremote" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        git reset ;\
        git checkout -f ;\
        git pull --ff'';
      "nix.update" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo chown -R me:users * &&\
        sudo chown -R me:users .git &&\
        alejandra --quiet . &&\
        mkdir -p .attic/flake.lock &&\
        cp -f flake.lock .attic/flake.lock/$(date '+%Y-%m-%d--%H-%M').flake.lock ;\
        git reset &&\
        git add . &&\
        git commit -S -m update ;\
        git reflog expire --expire-unreachable=now --all ;\
        git gc --prune=now ;\
        git fsck --full ;\
        git gc --aggressive ;\
        nix flake update ;\
        alejandra --quiet .'';
      "nix.boot" = ''
        nix.build &&\
        sudo nixos-rebuild boot -v --fallback --install-bootloader '';
      "nix.offlinebuild" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo alejandra --quiet . &&\
        sudo chown -R me:users .git &&\
        git reset &&\
        git add . &&\
        git commit -S -m update ;\
        export DTS="-$(date '+%Y-%m-%d--%H-%M')" ;\
        export HNAME="$(hostname)" ;\
        echo "############# ---> NIXOS-REBUILD NixOS [$HNAME-$DTS] <--- ##################" &&\
        sudo nixos-rebuild boot -v --option use-binary-caches false --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS-offline" '';
      "nix.switch" = ''
        export HNAME="$(hostname)" ;\
        export DTS="-$(date '+%Y-%m-%d--%H-%M')" ;\
        sudo nixos-rebuild switch --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS"'';
      "nix.build" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo alejandra --quiet . &&\
        sudo chown -R me:users .git &&\
        git reset &&\
        git add . &&\
        git commit -S -m update ;\
        export DTS="-$(date '+%Y-%m-%d--%H-%M')" ;\
        export HNAME="$(hostname)" ;\
        echo "############# ---> NIXOS-REBUILD NixOS [$HNAME-$DTS] <--- ##################" &&\
        sudo nom build .#nixosConfigurations.$HNAME.config.system.build.toplevel ;\
        sudo rm -f result ;\
        sudo nixos-rebuild boot --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS"'';
      "nix.cacheall" = ''
        cd /etc/nixos &&\
        nix.update ;\
        cd && mkdir -p cache && cd cache &&\
        nixos-rebuild build -v --fallback --flake /etc/nixos/#nixos ;\
        nix.sign'';
      "nix.iso" = ''
        cd /etc/nixos &&\
        NIXPKGS_ALLOW_BROKEN=1 nix build --impure -L .#nixosConfigurations.iso.config.system.build.isoImage &&\
        cd /etc/nixos/result/iso && ls -la'';
    };
  };
}
