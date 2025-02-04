#!/bin/sh
sudo -v
wazuh_stop() {
	echo "[WAZUH.INIT] Trying to terminate docker container, if already running ..."
	sudo systemctl stop docker-wazuh-indexer.service >/dev/null 2>&1
	sudo systemctl stop docker-wazuh-manager.service >/dev/null 2>&1
	sudo systemctl stop docker-wazuh-dashboard.service >/dev/null 2>&1
	sudo systemctl stop docker-wazuh-indexer.service >/dev/null 2>&1
	sudo systemctl stop docker-wazuh-manager.service >/dev/null 2>&1
	sudo systemctl stop docker-wazuh-dashboard.service >/dev/null 2>&1
}
case $1 in
stop) wazuh_stop && exit 0 ;;
esac
TARGET="/var/lib/wazuh"
if [ -x $TARGET ]; then
	DTS="$(date '+%Y%m%d%H%M')"
	echo "[WAZUH.INIT] Found pre-existing wazuh $TARGET, moving old config to $TARGET-$DTS"
	sudo rm -rf $TARGET-$DTS >/dev/null 2>&1
	sudo mv -f $TARGET $TARGET-$DTS
fi
sudo mkdir -p $TARGET && cd $TARGET
nix-shell --packages git --run "sudo git clone --depth 1 --branch 4.10.2 https://github.com/wazuh/wazuh-docker wazuh-docker"
cd wazuh-docker/single-node
nix-shell --packages docker docker-compose --run "sudo docker-compose -f generate-indexer-certs.yml run --rm generator"
sudo cp -af * ../..
cd $TARGET && sudo rm -rf wazuh-docker
exit 0
