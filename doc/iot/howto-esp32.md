sudo bash
nix-shell -p pipx
pipx install esptool
export PATH=$PATH:/root/.local/bin
unzip firmware.zip [https://github.com/meshtastic/firmware/releases heltecv3: esp32s3] 
sh ./device-install.sh -f firmware-heltec-v3-x.xx.xx.xxxx.factory.bin
rm -rf /root/.cache /root/.local | or reboot on impermanence
