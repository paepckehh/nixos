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
      export GIT="/run/current-system/sw/bin/git"
      export MKDIR="/run/current-system/sw/bin/mkdir"
      export MIRROR="${infra.git-mirror.storage}"
      export REPOS="${lib.strings.concatLines infra.git-mirror.repos}"
    '';
    "scripts/git-mirror-gc-full.sh".text = ''
      #/bin/sh
      source /etc/scripts/git-mirror-config.sh
      for repo in $REPOS; do
      	dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
      	echo "### git full maintenance: $dir"
      	cd $dir && if [ -f config ]; then $GIT gc --aggressive --keep-largest --prune=now && $GIT fsck --full ; fi
      done
    '';
    "scripts/git-mirror-gc.sh".text = ''
      #/bin/sh
      source /etc/scripts/git-mirror-config.sh
      for repo in $REPOS; do
      	dir="$MIRROR/$(echo $repo | tee | cut -d '#' -f 1)"
      	echo "### git maintenance: $dir"
      	cd $dir && if [ -f config ]; then $GIT gc --keep-largest ; fi
      done
    '';
    "scripts/git-mirror-fetch.sh".text = ''
      #/bin/sh
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
            $GIT gc --aggressive
        fi
      done
    '';
  };
}
