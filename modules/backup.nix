{
  config,
  pkgs,
  lib,
  ...
}: {
  #######################################################################################
  # REMINDER: To use this any of this functions, you *MUST* be memeber of group backup. #
  #######################################################################################

  ###############
  # ENVIRONMENT #
  ###############
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
        cd && tar -cf - . | zstd --compress -4 --exclude-compressed --auto-threads=physical --threads=0 -o $REPO_PATH/$FILE.tgz &&\
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
                compact) XCMD="git -C $REPO reflog expire --expire-unreachable=now --all" && action && XCMD="git -C $REPO gc -prune=now --aggressive" && action ;;
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
    '';
  };
  #########
  # USERS #
  #########
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

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    timers."git-update-every-hour" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "30m";
        OnUnitActiveSec = "120m";
        Unit = "git-update-every-hour.service";
      };
    };
    services."git-update-every-hour" = {
      path = [pkgs.git];
      script = ''${pkgs.bash}/bin/bash --posix /etc/gitops.sh update'';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
