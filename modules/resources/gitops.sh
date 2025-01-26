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
		update)
			case "$(git -C $REPO config get core.bare)" in
			false) XCMD="git -C $REPO pull --all --force" && action && XCMD="git -C $REPO gc --auto" && action ;;
			true) XCMD="git -C $REPO fetch --all --force" && action && XCMD="git -C $REPO gc --auto" && action ;;
			*) continue ;; # not a git repo
			esac
			;;
		*) echo "Please choose one of the following actions: [update|compact|repair|fetch|pull]" ;;
		esac
	done
done
sudo chown -R $REPO_OWNER:$REPO_GROUP $REPO_STORE
sudo chmod -R g=rwX $REPO_STORE
