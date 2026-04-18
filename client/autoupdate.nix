{
  lib,
  pkgs,
  ...
}: {
  ###############
  #-= SYSTEM #=-#
  ###############
  system.autoUpgrade.enable = lib.mkForce false;

  ################
  #-= SYSTEMD #=-#
  ################
  systemd = {
    timers."nix-update" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "25m";
        OnUnitActiveSec = "55m";
        Unit = "nix-updater.service";
      };
    };
    services."nix-updater" = {
      script = ''
        #!/bin/sh
        set -eu
        export LANG=C
        export PATH="/run/current-system/sw/bin:$PATH"
        DOMAIN="dbt.corp"
        HOST="$(/run/current-system/sw/bin/hostname)"
        PREFIX="$(echo $HOST | cut -c 1-2)"
        BRANCH="false"
        ROLE="false"
        echo "Found prefix: $PREFIX ; Based on hostname: $HOST"
        case $PREFIX in
        ti)
        	BRANCH="ti"
        	ROLE="ti"
        	;;
        op | po | fe | fb | gl)
        	BRANCH="office"
        	ROLE="office"
        	;;
        it)
        	BRANCH="main"
        	ROLE="$HOST"
        	;;
        mo)
        	BRANCH="main"
        	ROLE="moni"
        	;;
        *)
        	echo "... host prefix not detected!"
        	echo "... invalid hostname, most likely nixos or other default!"
        	echo "... please assign via DHCP a proper hostname, ip and role!"
        	echo "EXIT NOW!"
        	exit 1
        	;;
        esac
        echo "SWITCHING SYSTEM ROLE: $ROLE / BRANCH $BRANCH / BINARY PATH: $PATH"
        STATE="$(/run/current-system/sw/bin/host -t txt _autoupdate-$PREFIX.$DOMAIN | cut -c 43-46)"
        case $STATE in
        true)
        	echo "DETECT: $STATE _autoupdate-$PREFIX.$DOMAIN state detected in state true!"
        	echo "Starting autoupdate now!"
        	;;
        fals)
        	echo "DETECT: $STATE _autoupdate-$PREFIX.$DOMAIN state detected in state false!"
        	echo "EXIT NOW!"
        	exit 0
        	;;
        *)
        	echo "DETECT: $STATE ... unable to detect dns type txt _autoupdate-$PREFIX.$DOMAIN state."
        	echo "EXIT NOW!"
        	exit 1
        	;;
        esac
        case $HOST in
        ops*) echo "oooops ... ops server detectd, exit!" && exit 1 ;; # emergency gate
        srv*) echo "oooops ... ops server detectd, exit!" && exit 1 ;; # emergency gate
        esac
        cd /etc/nixos || exit 1
        /run/current-system/sw/bin/chown -R me:me /etc/nixos || exit 1
        /run/current-system/sw/bin/git switch $BRANCH || exit 1
        if /run/current-system/sw/bin/git pull | grep -q 'Already'; then
        	echo "no changes in upstream nixos repo"
        else
        	export FLAKE="/etc/nixos/#$ROLE"
        	export PDONE="/nix/persist/.profile-cleanup-done"
        	rm /etc/nixos/flake.lock || true
        	/run/current-system/sw/bin/git checkout . || true
        	/run/current-system/sw/bin/git pull --rebase || true
        	/run/current-system/sw/bin/git pull --force || true
        	/run/current-system/sw/bin/nixos-rebuild boot --flake $FLAKE || true
        	/run/current-system/sw/bin/git gc --force || true
        	/run/current-system/sw/bin/chown -R me:me /etc/nixos || true
        	/run/current-system/sw/bin/systemctl restart nix-gc.service
        	/run/current-system/sw/bin/systemctl restart nix-gc.service
        fi
        echo "SUCCESS: Finish nixos updater!"
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = false;
      };
    };
  };
}
