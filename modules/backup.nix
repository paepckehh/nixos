{
  config,
  pkgs,
  lib,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "backup.home" = ''
        env sudo -v && cd\
        export REPO_ROOT="/home" &&\
        export REPO_OWNER="backup" &&\
        export REPO_GROUP="backup" &&\
        export REPO_STORE=$REPO_ROOT/$REPO_OWNER &&\
        export REPO_PATH="$REPO_STORE/home" &&\
        export DTS=$(date '+%Y-%m-%d-%H-%M') &&\
        export FILE=$USER-$DTS.tgz &&\
        export LINK=$USER-current.tgz &&\
        sudo mkdir -p $REPO_PATH &&\
        sudo chown -R $REPO_OWNER:$REPO_GROUP $REPO_STORE &&\
        sudo chmod -R g=rwX $REPO_STORE &&\
        echo "[BACKUP.HOME] Performing backup a full backup of $PWD to $REPO_PATH/$FILE" &&\
        cd && sudo tar -cf - . | sudo zstd --compress -4 --exclude-compressed --auto-threads=physical --threads=0 -o $REPO_PATH/$FILE.tgz &&\
        sudo rm -rf $LINK > /dev/null 2>&1 &&\
        sudo ln -fs $FILE $LINK &&\
        sudo chown -R $REPO_OWNER:$REPO_GROUP $REPO_STORE &&\
        sudo chmod -R g=rwX $REPO_STORE'';
      "restore.home" = ''
        env sudo -v &&\
        export LINK=$USER-current.tgz &&\
        export PERM=$(id -u):$(id -g) &&\
        export BPATH=/home/backup/home &&\
        cd && sudo tar -xvf /home/backup/$LINK . &&\
        sudo chown -R $PERM .'';
      "backup.gitupdate" = ''
        env sudo -v &&\
        sudo sh /etc/gitops.sh update'';
    };
    etc."gitops.sh".text = lib.mkForce ''
      #!/bin/sh
      export REPO_ROOT="/home"
      export REPO_OWNER="backup"
      export REPO_GROUP="backup"
      export REPO_STORE="$REPO_ROOT/$REPO_OWNER"
      export REPO_PATH="$REPO_STORE/repos"
      sudo -v
      sudo mkdir -p $REPO_PATH
      sudo chown -R $REPO_OWNER:$REPO_GROUP $REPO_STORE
      sudo chmod -R g=rwX $REPO_STORE

      action() {
      	echo "### $XCMD"
      	sudo -u $REPO_OWNER $XCMD
      }

      ls $REPO_PATH | while read target; do
      	FOLDER=$REPO_PATH/$target
      	if [ ! -d $FOLDER ]; then continue; fi
      	ls $FOLDER | while read sub; do
      		REPO=$FOLDER/$sub
      		if [ ! -d $REPO ]; then continue; fi
      		if [ ! -d $REPO/.git ]; then continue; fi
      		echo "############################################################"
      		echo "$REPO" | sudo -u $REPO_OWNER tee $REPO/.git/description
      		case $1 in
      		fetch) XCMD="git -C $REPO fetch --all --force" && action && XCMD="git gc --auto" && action ;;
      		pull) XCMD="git -C $REPO pull --all --force" && action && XCMD="git gc --auto" && action ;;
      		compact) XCMD="git -C $REPO gc --aggressive" && action ;;
      		repair) XCMD="sudo -C $REPO git fsck" && action ;;
      		update) XCMD="sudo git -C $REPO pull --all --force" && action && XCMD="git -C $REPO gc --auto" && action ;;
      		*) echo "Please choose one of the following actions: [update|compact|repair|fetch|pull]" ;;
      		esac
      	done
      done
      sudo chown -R $REPO_OWNER:$REPO_GROUP $REPO_STORE
      sudo chmod -R g=rwX $REPO_STORE
    '';
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      "backup" = {
        isNormalUser = true;
        description = "backup user";
        initialHashedPassword = null; # disable interactive login
        uid = 6688;
        group = "backup";
        createHome = true;
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # disable pubkey auth
      };
    };
    groups = {
      backup.gid = 6688;
    };
  };
}
