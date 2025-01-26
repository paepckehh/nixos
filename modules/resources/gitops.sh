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
