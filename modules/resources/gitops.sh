#!/bin/sh
action() {
	echo "### $XCMD" && $XCMD
}
export REPO_ROOT="/home"
export REPO_OWNER="backup"
export REPO_GROUP="backup"
export REPO_STORE="$REPO_ROOT/$REPO_OWNER"
export REPO_PATH="$REPO_STORE/repos"
export SUDO_CMD=""
if [ $(id -u) -ne 0 ]; then
	SUDO_CMD="sudo"
	$SUDO_CMD -v
fi
$SUDO_CMD chown -R $REPO_OWNER:$REPO_GROUP $REPO_STORE
$SUDO_CMD chmod -R g=rwX $REPO_STORE
if [ ! -d $REPO_PATH ]; then
	echo "[GITOPS] Init: First Run!"
	mkdir -p $REPO_PATH/pvz
	XCMD="git -C $REPO_PATH/pvz clone --progress https://git.admin.lan/pvz/nixos.git nixos" && action
fi
ls $REPO_PATH | while read target; do
	FOLDER=$REPO_PATH/$target
	if [ ! -d $FOLDER ]; then continue; fi
	ls $FOLDER | while read sub; do
		REPO=$FOLDER/$sub
		if [ ! -d $REPO ]; then continue; fi
		if [ ! -d $REPO/.git ]; then continue; fi
		echo "############################################################"
		echo "$REPO" | cat $REPO/.git/description
		case $1 in
		fetch) XCMD="git -C $REPO fetch --all --force" && action && XCMD="git gc --auto" && action ;;
		pull) XCMD="git -C $REPO pull --all --force" && action && XCMD="git gc --auto" && action ;;
		compact) XCMD="git -C $REPO gc --aggressive" && action ;;
		repair) XCMD="git -C $REPO git fsck" && action ;;
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
$SUDO_CMD chown -R $REPO_OWNER:$REPO_GROUP $REPO_STORE
$SUDO_CMD chmod -R g=rwX $REPO_STORE
