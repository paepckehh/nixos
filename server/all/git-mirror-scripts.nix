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
    "scripts/git-mirror-config.sh".text = ''
      #!/bin/sh
      if [ "$EUID" -ne 0 ]; then echo "Please run this script as root!" && exit 1 ; fi
      export GIT="/run/current-system/sw/bin/git"
      export MKDIR="/run/current-system/sw/bin/mkdir"
      export CHOWN="/run/current-system/sw/bin/chown"
      export CHMOD="/run/current-system/sw/bin/chmod"
      export MIRROR="${infra.git-mirror.storage}"
      export REPOS="${lib.strings.concatLines infra.git-mirror.repos}"
      $MKDIR -p $MIRROR
      $CHOWN -R 0:0 $MIRROR
      $CHMOD -R 755 $MIRROR
    '';
    "scripts/git-mirror-repo-config.sh".text = ''
      #/bin/sh
      source /etc/scripts/git-mirror-config.sh
      $GIT config pack.allowPackReuse multi
      $GIT config pack.deltaCacheSize 0
      $GIT config pack.deltaCacheLimit 65535
      $GIT config pack.threads 0
      $GIT config pack.indexVersion 2
      $GIT config pack.useBitmapBoundaryTraversal true
      $GIT config pack.useSparse true
      $GIT config pack.writeBitmapHashCache true
      $GIT config pack.writeBitmapLookupTable true
      $GIT config repack.useDeltaBaseOffset true
      $GIT config repack.useDeltaIslands true
      $GIT config repack.writeBitmaps true
    '';
    "scripts/git-mirror-gc.sh".text = ''
      #!/bin/sh
      source /etc/scripts/git-mirror-config.sh
      for repo in $REPOS; do
      	dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
      	echo "### git gc maintenance: $dir"
        cd $dir && if [ -f config ]; then
            sh /etc/scripts/git-mirror-repo-config.sh
            $GIT gc --keep-largest
        fi
      done
    '';
    "scripts/git-mirror-gc-full.sh".text = ''
      #!/bin/sh
      source /etc/scripts/git-mirror-config.sh
      for repo in $REPOS; do
      	dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
      	echo "### git gc full maintenance: $dir"
        cd $dir && if [ -f config ]; then
            sh /etc/scripts/git-mirror-repo-config.sh
            $GIT gc --aggressive --keep-largest --prune=now
        fi
      done
    '';
    "scripts/git-mirror-gc-max.sh".text = ''
      #!/bin/sh
      source /etc/scripts/git-mirror-config.sh
      for repo in $REPOS; do
      	dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
      	echo "### git gc max maintenance: $dir"
        cd $dir && if [ -f config ]; then
            sh /etc/scripts/git-mirror-repo-config.sh
            $GIT gc --aggressive --prune=now
            $GIT fsck --full
        fi
      done
    '';
    "scripts/git-mirror-fetch.sh".text = ''
      #!/bin/sh
      source /etc/scripts/git-mirror-config.sh
      for repo in $REPOS; do
      	dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
      	url="$(echo $repo | tee | cut -d '#' -f 2)"
        echo "### fetch/update/check/mirror: $dir => $url"
        $MKDIR -p $dir && cd $dir || exit 1
        if [ -f config ]; then
            $GIT fetch
        else
            $GIT clone --mirror $url .
            sh /etc/scripts/git-mirror-repo-config.sh
            $GIT gc --aggressive --prune-now
        fi
      done
    '';
  };
}
