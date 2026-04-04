{
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc."scripts/home-fix.sh".text = ''
    #!/bin/sh
    action() {
            dir="$1"
            ini="$dir/profiles.ini"
            bck="$dir/profiles.ini.backup"
            echo "Check: $bck"
            if [ -e $bck ]; then
                    echo "Found: $bck, migrate: $dir"
                    dts="$($exe/date +%Y%m%d%H%M%S)"
                    wip="$dir/profiles.ini.wip.$dts"
                    done="$dir/profiles.ini.done.$dts"
                    $exe/mv $bck $wip
                    $exe/cat $wip | while read line; do
                            key=$(echo $line | $exe/cut -d '=' -f 1)
                            value=$(echo $line | $exe/cut -d '=' -f 2)
                            case $key in
                            Path)
                                    if [ -x $dir/$path ]; then
                                            if [ -x "$dir/default" ]; then
                                                    $exe/mv "$dir/default" "$dir/default.$dts"
                                                    $exe/mv "$dir/$value" "$dir/default"
                                                    $exe/mv "$wip" "$done"
                                                    echo "Migration: $dir : done!"
                                                    exit 0
                                            fi
                                    fi
                                    ;;
                            esac
                    done
            fi
    }

    # setup
    USERNAME="$1"
    HOMEDIR="/nix/persist/home"
    USERHOME="$HOMEDIR/$USERNAME"
    exe="/run/current-system/sw/bin"
    $exe/mkdir -p $HOMEDIR
    $exe/chmod 700 $HOMEDIR
    $exe/chown -R $USERNAME:$USERNAME $HOMEDIR
    # main
    action "$USERHOME/.thunderbird"
    action "$USERHOME/.librewolf"
    action "$USERHOME/.mozilla"
    if [ -r $USERHOME/.face ]; then cp -af $USERHOME/.face /var/lib/AccountsService/icons/$USERNAME; fi
  '';
}
