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
    "scripts/git-mirror-gc.sh".text = ''
      #/bin/sh
      export GIT="/run/current-system/sw/bin/git"
      export OPT1="--aggressive"
      export OPT2="--keep-largest"
      export MIRROR="/nix/persist/cache/git-mirror"
      /run/current-system/sw/bin/chown -R 0:0 "$MIRROR" || exit 1
      $GIT -C "$MIRROR/paepckehh/nixos" gc "$OPT1"
      $GIT -C "$MIRROR/ryantm/agenix" gc "$OPT1"
      $GIT -C "$MIRROR/nix-community/disko" gc "$OPT1"
      $GIT -C "$MIRROR/nix-community/home-manager" gc "$OPT1"
      $GIT -C "$MIRROR/nixos/nixpkgs" gc "$OPT1" "$OPT2"
    '';
    "scripts/git-mirror-fetch.sh".text = ''
      #/bin/sh
      export GIT="/run/current-system/sw/bin/git"
      export MIRROR="/nix/persist/cache/git-mirror"
      /run/current-system/sw/bin/chown -R 0:0 "$MIRROR" || exit 1
      $GIT -C "$MIRROR/paepckehh/nixos" fetch
      $GIT -C "$MIRROR/ryantm/agenix" fetch
      $GIT -C "$MIRROR/nix-community/disko" fetch
      $GIT -C "$MIRROR/nix-community/home-manager" fetch
      $GIT -C "$MIRROR/nixos/nixpkgs" fetch
    '';
  };
}
