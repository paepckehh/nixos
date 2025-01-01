{
  config,
  pkgs,
  lib,
  modulesPath,
  targetSystem,
  ...
}: let
  installerFailsafe = pkgs.writeShellScript "failsafe" ''
    ${lib.getExe installer} || echo "ERROR: Installation failure!"
    sleep 3600'';
  installer = pkgs.writeShellApplication {
    name = "installer";
    runtimeInputs = with pkgs; [
      dosfstools
      e2fsprogs
      gawk
      nixos-install-tools
      util-linux
      config.nix.package
    ];
    text = ''

      info() {
      	echo ""
      	echo ""
      	echo "   ######################################"
      	echo "   # -=!*** [ NIXOS-AUTO-SETUP ] ***!=- #"
      	echo "   ######################################"
      	echo ""
      	echo ""
      	echo ""
      	echo "[NIX-AUTO] Lets try to find a usable disk."
      	echo "[NIX-AUTO] This is your current storage device list."
      	echo "############################################################"
      	lsblk
      	echo "############################################################"
      }

      action() {
      	echo "[NIX-AUTO] Starting $DEVICE_MAIN full disk wipe."
        wipefs --all --force "$DEVICE_MAIN"
        sync
        dd if=/dev/zero of="$DEVICE_MAIN" oflag=direct bs=1M count=128 > /dev/null 2>&1
        sync
        wipefs --all --force "$DEVICE_MAIN"
        sync
        echo "[NIX-AUTO] Finish Disk wipe $DEVICE_MAIN."
      	echo "[NIX-AUTO] Starting $DEVICE_MAIN partition table create."
        DISKO_DEVICE_MAIN=''${DEVICE_MAIN#"/dev/"} ${targetSystem.config.system.build.diskoScript} 2> /dev/null
        sync
        echo "[NIX-AUTO] Finish $DEVICE_MAIN partition tables create."
      	echo "[NIX-AUTO] Starting installation NixOS now on $DEVICE_MAIN"
        nixos-install --keep-going --no-root-password --max-jobs 0 --cores 0 --option substituters "" --system ${targetSystem.config.system.build.toplevel}
        sync
      	echo "[NIX-AUTO] Finish installation NixOS on $DEVICE_MAIN"
      	echo "############################################################"
        lsblk
      	echo "############################################################"
      }

      loop() {
      	DEVICE_MAIN=""
      	for DEVICE_MAIN in $(lsblk -pln -o NAME,TYPE | grep disk | awk '{ print $1 }'); do
      		echo "[NIX-AUTO] Testing Disk: $DEVICE_MAIN"
      		case "$DEVICE_MAIN" in
      		/dev/sd*)

      			echo "[NIX-AUTO] Found a Legacy Disk: $DEVICE_MAIN"
      			BUSTYPE="$(udevadm info --query=all --name="$DEVICE_MAIN" | grep ID_BUS | cut -d = -f 2)"
      			case $BUSTYPE in
      			usb)
      				echo "[NIX-AUTO] [ERROR:USB] Legacy Disk: $DEVICE_MAIN is a usb device, skip it."
      				continue
      				;;
      			*)
      				echo "[NIX-AUTO] [SUCCESS] Found Disk: $DEVICE_MAIN"
      				action
      				;;
      			esac
      			;;

      		/dev/zram*)
      			echo "[NIX-AUTO] [ERROR:ZRAM] Found Disk: $DEVICE_MAIN - This is your swap device, skip."
      			continue
      			;;
      		*)
      			echo "[NIX-AUTO] [SUCCESS] Found Disk: $DEVICE_MAIN"
      			action
      			;;

      		esac
      	done
      }

      finish() {
      	echo "[NIX-AUTO] All Actions done."
      	echo "[NIX-AUTO] Computer will poweroff in 12 seconds"
      	sleep 12
        poweroff
      }

      # main
      info
      loop
      debug
      finish
    '';
  };
in {
  imports = [
    # (modulesPath + "/installer/cd-dvd/iso-image.nix")
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    (modulesPath + "/profiles/all-hardware.nix")
  ];
  boot = {
    loader.timeout = lib.mkForce 0;
    kernelParams = ["systemd.unit=getty.target"];
    kernelPackages = pkgs.linuxPackages_latest;
  };
  console = {
    earlySetup = lib.mkForce true;
    keyMap = "us";
    font = "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v18b.psf.gz";
    packages = with pkgs; [powerline-fonts];
  };
  isoImage = {
    isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
    squashfsCompression = "zstd";
  };
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      ExecStart = ["" installerFailsafe];
      Restart = "no";
      StandardInput = "null";
    };
  };
  system.stateVersion = "24.11";
}
