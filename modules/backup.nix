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
        export DTS="-$(date '+%Y-%m-%d-%H-%M')" &&\
        export PATH=/home/backup/home
        export FILE=$USERNAME-$DTS.tgz &&\
        export LINK=$USERNAME-current.tgz &&\
        sudo mkdir $PATH &&\
        echo "[BACKUP.HOME] Performing backup a full backup of $PWD to $PATH/$FILE" &&\
        cd && sudo tar -cf - . | zstd --compress -18 --exclude-compressed --auto-threads=physical --threads=0 > /home/backup/home/$FILE.tgz
        sudo rm -rf $LINK > /dev/null 2>&1
        sudo ln -fs $FILE $LINK
        sudo chown -R backup:backup /home/backup'';
      "restore.home" = ''
        env sudo -v &&\
        export LINK=$USERNAME-current.tgz
        export PERM=$(id -u):$(id -g)
        cd && sudo tar -xvf /home/backup/$LINK .
        sudo chown -R $PERM'';
      "backup.gitupdate" = ''
        env sudo -v &&\
        sudo sh /etc/gitops.sh update'';
    };
    etc."etc/gitops.sh".text = lib.mkForce ''
      #!/bin/sh
      REPO_PATH="/home/backup/repo"
      REPO_OWNER="backup"
      REPO_GROUP="backup"

      action() {
      	echo "### $XCMD"
      	sudo -u $REPO_OWNER $XCMD
      }

      sudo -v
      sudo mkdir -p $REPO_PATH
      sudo chown -R $REPO_OWNER:$REPO_GROUP $REPO_PATH

      cd $REPO_PATH && {
      	ls | while read target; do
      		FOLDER=$REPO_PATH/$target
      		if [ ! -d $FOLDER ]; then continue; fi
      		cd $FOLDER && {
      			ls | while read sub; do
      				REPO=$FOLDER/$sub
      				if [ ! -d $REPO ]; then continue; fi
      				cd $REPO && {
      					if [ ! -d .git ]; then continue; fi
      					echo "############################################################"
      					echo "$REPO" | sudo -u cgit tee .git/description
      					case $1 in
      					fetch) XCMD="git fetch --all --force" && action && XCMD="git gc --auto" && action ;;
      					pull) XCMD="git pull --all --force" && action && XCMD="git gc --auto" && action ;;
      					compact) XCMD="git gc --aggressive" && action ;;
      					repair) XCMD="sudo git fsck" && action ;;
      					update)
      						if [ -d .git ]; then
      							echo "### git repo mode"
      							XCMD="sudo git fetch --all --force" && action && XCMD="git gc --auto" && action
      						else
      							echo "### git worktree mode"
      							XCMD="sudo git pull --all --force" && action && XCMD="git gc --auto" && action
      						fi
      						;;
      					*) echo "Please choose one of the following actions: [update|compact|repair|fetch|pull]" ;;
      					esac
      				}
      			done
      		}
      	done
      }
      sudo chown -R $REPO_OWNER:$REPO_GROUP $PATH
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
