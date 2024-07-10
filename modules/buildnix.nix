{config, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "nix.push" = ''
        cd /etc/nixos &&\
        sudo -v &&\
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
        sudo -v &&\
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
        nix.all ;\
        sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 1d ;\
        sudo nix-collect-garbage --delete-older-than 1d ;\
        sudo nix-store --gc ;\
        sudo nix-store --optimise '';
      "nix.test" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . ;\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        sudo nixos-rebuild dry-activate --flake /etc/nixos/.#$(hostname)'';
      "nix.iso" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . &&\
        git reset ;\
        git add . ;\
        git commit -S -m update ;\
        export HNAME="$(hostname)" ;\
        sudo nix build --impure ".#nixosConfigurations.$HNAME-iso.config.system.build.isoImage" ;\
        eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename /result/iso '';
      "nix.update" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo nix flake lock --update-input nixpkgs --update-input nixos-hardware --update-input home-manager ;\
        sudo alejandra --quiet . &&\
        sudo nixos-generate-config &&\
        sudo alejandra --quiet . '';
      "nix.switch" = ''
        nix.build ;\
        sudo nixos-rebuild switch --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" '';
      "nix.build" = ''
        cd /etc/nixos &&\
        sudo -v &&\
        sudo alejandra --quiet . &&\
        sudo nixos-generate-config &&\
        sudo alejandra --quiet . &&\
        nix.push ;\
        export DTS="$(date '+%Y-%m-%d-(%H-%M)')" ;\
        export HNAME="$(hostname)" ;\
        echo "############# ---> Rebuild for HOST: $HNAME TIMESTAMP: $DTS <--- ##################"
        sudo nixos-rebuild boot --install-bootloader ;\
        sudo nixos-rebuild boot --flake "/etc/nixos/.#$HNAME" -p "$HNAME-$DTS" '';
      "nix.all" = ''
        nix.update ;\
        nix.build ;\
        echo "############# ---> Rebuild **all** for HOST: $HNAME TIMESTAMP: $DTS <--- ##########"
        sudo nixos-rebuild boot --flake /etc/nixos/#generic              -p "generic-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#generic-console      -p "generic-console-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixmac182            -p "nixmac182-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixbook141           -p "nixbook141-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixbook141-office    -p "nixbook141-office-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixbook141-hyprland  -p "nixbook141-hyprland-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#nixbook141-console   -p "nixbook141-console-$DTS" -v ;\
        sudo nixos-rebuild boot --flake /etc/nixos/#$HNAME               -p "$HNAME-$DTS" -v '';
    };
  };
}
