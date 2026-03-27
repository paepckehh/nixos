# git mirror updater, git maintenance
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc = {
    "scripts/git-mirror-gc-full.sh".text = ''
      #/bin/sh
      export GIT="/run/current-system/sw/bin/git"
      export MIRROR="/nix/persist/cache/git-mirror"
      /run/current-system/sw/bin/chown -R 0:0 "$MIRROR" || exit 1
      $GIT -C "$MIRROR/paepckehh/nixos"            gc --aggressive --prune=now
      $GIT -C "$MIRROR/ryantm/agenix"              gc --aggressive --prune=now
      $GIT -C "$MIRROR/nix-community/disko"        gc --aggressive --prune=now
      $GIT -C "$MIRROR/nix-community/home-manager" gc --aggressive --prune=now
      $GIT -C "$MIRROR/nixos/nixpkgs"              gc --aggressive --prune=now
      $GIT -C "$MIRROR/paepckehh/nixos"            fsck --full
      $GIT -C "$MIRROR/ryantm/agenix"              fsck --full
      $GIT -C "$MIRROR/nix-community/disko"        fsck --full
      $GIT -C "$MIRROR/nix-community/home-manager" fsck --full
      $GIT -C "$MIRROR/nixos/nixpkgs"              fsck --full
    '';
    "scripts/git-mirror-gc.sh".text = ''
      #/bin/sh
      export GIT="/run/current-system/sw/bin/git"
      export MIRROR="/nix/persist/cache/git-mirror"
      /run/current-system/sw/bin/chown -R 0:0 "$MIRROR" || exit 1
      $GIT -C "$MIRROR/paepckehh/nixos"            gc --keep-largest
      $GIT -C "$MIRROR/ryantm/agenix"              gc --keep-largest
      $GIT -C "$MIRROR/nix-community/disko"        gc --keep-largest
      $GIT -C "$MIRROR/nix-community/home-manager" gc --keep-largest
      $GIT -C "$MIRROR/nixos/nixpkgs"              gc --keep-largest
    '';
    "scripts/git-mirror-fetch.sh".text = ''
      #/bin/sh
      export GIT="/run/current-system/sw/bin/git"
      export MIRROR="/nix/persist/cache/git-mirror"
      /run/current-system/sw/bin/chown -R 0:0 "$MIRROR" || exit 1
      $GIT -C "$MIRROR/paepckehh/nixos"            fetch
      $GIT -C "$MIRROR/ryantm/agenix"              fetch
      $GIT -C "$MIRROR/nix-community/disko"        fetch
      $GIT -C "$MIRROR/nix-community/home-manager" fetch
      $GIT -C "$MIRROR/nixos/nixpkgs"              fetch
    '';
  };
}
