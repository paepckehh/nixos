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
  environment = {
    systemPackages = with pkgs; [git curl];
    etc = {
      "scripts/git-mirror-config.sh".text = ''
        #!/bin/sh
        if [ "$EUID" -ne 0 ]; then echo "Please run this script as root!" && exit 1 ; fi
        export CURL="/run/current-system/sw/bin/curl"
        export GIT="/run/current-system/sw/bin/git"
        export SH="/run/current-system/sw/bin/sh"
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
        $GIT config pack.indexVersion 1
        $GIT config --unset remote.origin.tagOpt
        $GIT config core.packedGitWindowSize 4g
        $GIT config pack.allowPackReuse true
        $GIT config pack.compression -1
        $GIT config pack.depth 50
        $GIT config pack.deltaCacheSize 512m
        $GIT config pack.deltaCacheLimit 1000
        $GIT config pack.threads 0
        $GIT config pack.useBitmapBoundaryTraversal true
        $GIT config pack.useSparse true
        $GIT config pack.window 10
        $GIT config pack.windowMemory 0
        $GIT config pack.writeBitmapHashCache true
        $GIT config pack.writeBitmapLookupTable true
        $GIT config repack.useDeltaBaseOffset true
        $GIT config repack.useDeltaIslands false
        $GIT config repack.writeBitmaps true
      '';
      "scripts/git-mirror-cache.sh".text = ''
        #!/bin/sh
        source /etc/scripts/git-mirror-config.sh
        for repo in $REPOS; do
           localurl="${infra.git-mirror.url}/$(echo $repo | tee | cut -d '#' -f 1)"
           echo "### cgit cache: $localurl"
           $CURL $localurl > /dev/null 2>&1 || true
        done
      '';
      "scripts/git-mirror-gc.sh".text = ''
        #!/bin/sh
        source /etc/scripts/git-mirror-config.sh
        for repo in $REPOS; do
           dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
           echo "### git gc maintenance: $dir"
           cd $dir && if [ -f config ]; then
              $SH /etc/scripts/git-mirror-repo-config.sh
              $GIT gc --keep-largest
           fi
        done
        $SH /etc/scripts/git-mirror-cache.sh
      '';
      "scripts/git-mirror-gc-full.sh".text = ''
        #!/bin/sh
        source /etc/scripts/git-mirror-config.sh
        for repo in $REPOS; do
        	dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
        	echo "### git gc full maintenance: $dir"
          cd $dir && if [ -f config ]; then
              $SH /etc/scripts/git-mirror-repo-config.sh
              $GIT gc --aggressive --keep-largest
          fi
        done
        $SH /etc/scripts/git-mirror-cache.sh
      '';
      "scripts/git-mirror-gc-max.sh".text = ''
        #!/bin/sh
        source /etc/scripts/git-mirror-config.sh
        for repo in $REPOS; do
        	dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
        	echo "### git gc max maintenance: $dir"
          cd $dir && if [ -f config ]; then
              $SH /etc/scripts/git-mirror-repo-config.sh
              $GIT gc --aggressive
              $GIT fsck --full
          fi
        done
        $SH /etc/scripts/git-mirror-cache.sh
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
              $SH /etc/scripts/git-mirror-repo-config.sh
              $GIT fetch --all --force --tags
          else
              $GIT clone --mirror $url .
              $SH /etc/scripts/git-mirror-repo-config.sh
              $GIT fetch --all --force --tags
              $GIT gc --aggressive
          fi
        done
        $SH /etc/scripts/git-mirror-cache.sh
      '';
    };
  };
}
