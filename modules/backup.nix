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
        env sudo -v && cd &&\
        export DTS=$(date '+%Y-%m-%d-%H-%M') &&\
        export BPATH=/home/backup/home &&\
        export FILE=$USER-$DTS.tgz &&\
        export LINK=$USER-current.tgz &&\
        sudo mkdir $BPATH &&\
        echo "[BACKUP.HOME] Performing backup a full backup of $PWD to $BPATH/$FILE" &&\
        cd && sudo tar -cf - . | sudo zstd --compress -4 --exclude-compressed --auto-threads=physical --threads=0 -o $BPATH/$FILE.tgz &&\
        sudo rm -rf $LINK > /dev/null 2>&1 &&\
        sudo ln -fs $FILE $LINK &&\
        sudo chown -R backup:backup $BPATH
        sudo chmod -R g=rwX $BPATH'';
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
      REPO_PATH="/home/backup/repos"
      REPO_OWNER="backup"
      REPO_GROUP="backup"

      action() {
      	echo "### $XCMD"
      	sudo -u $REPO_OWNER $XCMD
      }

      sudo -v
      sudo mkdir -p $REPO_PATH
      sudo chown -R $REPO_OWNER:$REPO_GROUP $REPO_PATH
      sudo chmod -R g=rwX $REPO_PATH

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
      					update)
      						if [ -d $REPO/.git ]; then
      							echo "### git repo mode"
      							XCMD="sudo git -C $REPO fetch --all --force" && action && XCMD="git -C $REPO gc --auto" && action
      						else
      							echo "### git worktree mode"
      							XCMD="sudo git -C $REPO pull --all --force" && action && XCMD="git -C $REPO gc --auto" && action
      						fi
      						;;
      					*) echo "Please choose one of the following actions: [update|compact|repair|fetch|pull]" ;;
      					esac
      			done
      	done
      sudo chown -R $REPO_OWNER:$REPO_GROUP $REPO_PATH
      sudo chmod -R g=rwX $REPO_PATH
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
