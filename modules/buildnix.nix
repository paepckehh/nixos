{config, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "nix.push" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        host github.com ;\
        host api.github.com ;\
        host cache.nixos.org ;\
        sudo alejandra --quiet . &&\
        sudo chown -R me:users .git &&\
        git reset &&\
        git add . &&\
        git commit -S -m update ;\
        git fsck --full &&\
        git gc --aggressive &&\
        git push --force '';
      "nix.clean" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 12d ;\
        sudo nix-collect-garbage --delete-older-than 12d ;\
        sudo nix-store --gc ;\
        sudo nix-store --optimise '';
      "nix.hardclean" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo rm /boot/loader/entries/* ;\
        sudo rm -rf /nix/var/nix/profiles/system* ;\
        sudo mkdir -p /nix/var/nix/profiles/system-profiles ;\
        nix.build &&\
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 1d ;\
        sudo nix-collect-garbage --delete-older-than 1d ;\
        sudo nix-store --gc ;\
        sudo nix-store --optimise '';
      "nix.hardclean.mp" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo rm /boot/loader/entries/* ;\
        sudo rm -rf /nix/var/nix/profiles/system* ;\
        sudo mkdir -p /nix/var/nix/profiles/system-profiles ;\
        nix.mp &&\
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
      "nix.iso" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo alejandra --quiet . &&\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        export HNAME="$(hostname)" ;\
        sudo nix build --impure ".#nixosConfigurations.$HNAME-iso.config.system.build.isoImage" ;\
        eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename /result/iso '';
      "nix.update" = ''
        cd /etc/nixos &&\
        env sudo -v &&\
        sudo alejandra --quiet . &&\
        sudo chown -R me:users .git &&\
        git reset &&\
        git add . &&\
        git commit -S -m update ;\
        git fsck --full &&\
        git gc --aggressive &&\
        sudo nix flake lock --update-input nixpkgs --update-input home-manager ;\
        sudo alejandra --quiet .'';
      "nix.switch" = ''
        nix.build ;\
        sudo nixos-rebuild switch --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" '';
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
        echo "############# ---> NIXOS-REBUILD NixOS [$HNAME-$DTS] <--- ##################"
        sudo nixos-rebuild boot --install-bootloader ;\
        sudo nixos-rebuild boot --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" '';
      "nix.mp" = ''
        nix.update ;\
        nix.build ;\
        echo "############# ---> NIXOS-REBUILD **all** NixOS-MP [$HNAME-$DTS] <--- ##########"
        sudo nixos-rebuild boot --flake /etc/nixos/#nixos-mp             -p "nixos-mp-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixos-console-mp     -p "nixos-console-mp-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#$HNAME               -p "$HNAME-$DTS" -v '';
      "nix.all" = ''
        nix.update ;\
        nix.build ;\
        echo "############# ---> NIXOS-REBUILD **all** NixOS [$HNAME-$DTS] <--- ##########"
        sudo nixos-rebuild boot --flake /etc/nixos/#nixos                -p "nixos-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixos-console        -p "nixos-console-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#$HNAME               -p "$HNAME-$DTS" -v '';
    };
  };
}
