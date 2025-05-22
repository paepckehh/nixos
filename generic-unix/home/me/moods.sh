#!/bin/sh
# info: sudo systemctl list-units --all --type=service
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo apt install systemd-zram-generator btop vim syslog-ng
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo swapoff -a
sudo systemctl disable auditd.service
sudo systemctl disable dphys-swapfile.service
sudo systemctl disable glamor-test.service
sudo systemctl disable gssproxy.service
sudo systemctl disable man-db.service
sudo systemctl disable ModemManager.service
sudo systemctl disable nfs-blkmap.service
sudo systemctl disable nfsdcld.service
sudo systemctl disable nfs-idmapd.service
sudo systemctl disable nfs-mountd.service
sudo systemctl disable nfs-server.service
sudo systemctl disable nfs-utils.service
sudo systemctl disable nmbd.service
sudo systemctl disable rpc-gssd.service
sudo systemctl disable rpc-statd-notify.service
sudo systemctl disable rpi-eeprom-update.service
sudo systemctl disable rsyslog.service
sudo systemctl disable samba-ad-dc.service
sudo systemctl disable systemd-firstboot.service
sudo systemctl disable systemd-hwdb-update.service
sudo systemctl disable systemd-pcrphase-initrd.service
sudo systemctl disable systemd-pcrphase.service
sudo systemctl disable systemd-pcrphase-sysinit.service
sudo systemctl disable winbind.service
sudo systemctl disable zram-swap-conf.service
sudo reboot
