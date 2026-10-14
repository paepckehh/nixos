{
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc."scripts/home-fix.sh".text = ''
    USERNAME="$1"
    HOMEDIR="/nix/persist/home"
    USERHOME="$HOMEDIR/$USERNAME"
    EXE="/run/current-system/sw/bin"
    $EXE/mkdir -p $HOMEDIR
    $EXE/chmod 700 $HOMEDIR
    $EXE/chown -R $USERNAME:$USERNAME $HOMEDIR
    if [ -r $USERHOME/.face ]; then cp -af $USERHOME/.face /var/lib/AccountsService/icons/$USERNAME; fi
  '';
}
