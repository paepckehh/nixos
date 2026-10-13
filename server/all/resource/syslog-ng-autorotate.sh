#!/bin/sh
LOGDIR="/var/syslog-ng"
ARCHIV="/nix/persist/archiv/logs"
FILES="console.txt console-err.txt console-crit.txt console-hostwatch.txt console-newstation.txt"
EXEC="/run/current-system/sw/bin"
DTS="$($EXEC/date +%Y-%m-%d-%H%M%S)"
SNAP="$LOGDIR/.$($EXEC/uuidgen)"
$EXEC/mkdir -p $SNAP $ARCHIV
$EXEC/chown -R 0:0 $SNAP $ARCHIV
$EXEC/chmod -R 700 $SNAP $ARCHIV
for file in $FILES; do
	$EXEC/touch $LOGDIR/$file
	$EXEC/link $LOGDIR/$file $SNAP/$file
done
$EXEC/systemctl stop syslog-ng.service
for file in $FILES; do
	$EXEC/unlink $LOGDIR/$file
done
if [ "$1" != "down" ]; then $EXEC/systemctl start syslog-ng.service; fi
for file in $FILES; do
	$EXEC/cat $SNAP/$file | $EXEC/xz -9e --compress --stdout > $ARCHIV/$DTS.$file.xz
	$EXEC/unlink $SNAP/$file
	$EXEC/sync
done
$EXEC/rm -rf $SNAP
$EXEC/chown -R 0:0 $ARCHIV
$EXEC/chmod -R 700 $ARCHIV
$EXEC/ln -sf /nix/persist/archiv/logs /var/syslog-ng/ || true
