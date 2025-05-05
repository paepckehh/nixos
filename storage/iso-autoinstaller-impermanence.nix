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
      nvme-cli
      config.nix.package
    ];
    text = ''
      #!/bin/sh

      # SETUP
      export LUKS_PASSWORD="start"

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
      	echo "[NIX-AUTO] Starting $DEVICE_MAIN full disk wipefs."
        wipefs --all --force "$DEVICE_MAIN"
      	echo "[NIX-AUTO] Finish of $DEVICE_MAIN full disk wipefs."
      	echo "[NIX-AUTO] Starting $DEVICE_MAIN overwrite first 1GB with zeros."
        dd if=/dev/zero of="$DEVICE_MAIN" oflag=direct bs=1M count=1024 > /dev/null 2>&1
      	echo "[NIX-AUTO] Finish $DEVICE_MAIN overwrite first 1GB with zeros."
        sync
      	case "$DEVICE_MAIN" in
                /dev/nvme*)
                echo "[NIX-AUTO] NVME Detected, perform factory reset on $DEVICE_MAIN."
                echo "[NIX-AUTO] Starting factory reset on $DEVICE_MAIN."
                nvme format "$DEVICE_MAIN" --force
                echo "[NIX-AUTO] Finish factory reset on $DEVICE_MAIN."
                ;;
                *)
        esac
        sync
        echo "[NIX-AUTO] Finish Disk wipe $DEVICE_MAIN."
        echo "[NIX-AUTO] Starting $DEVICE_MAIN partition table create."
        echo "$LUKS_PASSWORD" > /tmp/luks
        echo "[NIX-AUTO] Setting Luks Password: $LUKS_PASSWORD"
        DISKO_DEVICE_MAIN=''${DEVICE_MAIN#"/dev/"} ${targetSystem.config.system.build.diskoScript} 2> /dev/null
        df -h

        echo "[NIX-AUTO] create impermanence structure"
        sudo mkdir -p /mnt/boot /mnt/nix /mnt/home /mnt/var/lib /mnt/etc/nixos /mnt/etc/ssh /mnt/nix/var/log /mnt
        sudo mkdir -p /mnt/nix/persist/home /mnt/nix/persist/var/lib /mnt/nix/persist/etc/nixos /mnt/nix/persist/etc/ssh
        sudo mount -o bind /mnt/nix/persist/home /mnt/home
        sudo mount -o bind /mnt/nix/persist/var/lib /mnt/var/lib
        sudo mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
        sudo mount -o bind /mnt/nix/persist/etc/ssh /mnt/etc/ssh

        df -h
        exit 1
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
      finish
    '';
  };
in {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];
  boot = {
    loader = {
      timeout = lib.mkForce 1;
      grub.memtest86.enable = lib.mkForce false;
    };
    kernelParams = ["systemd.unit=getty.target"];
    kernelPackages = pkgs.linuxPackages_latest;
  };
  console = {
    earlySetup = lib.mkForce true;
    keyMap = "us";
    font = "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v18b.psf.gz";
    packages = with pkgs; [powerline-fonts];
  };
  documentation = {
    man.enable = lib.mkForce false;
    doc.enable = lib.mkForce false;
  };
  fonts.fontconfig.enable = lib.mkForce false;
  networking = {
    enableIPv6 = lib.mkForce false;
    useDHCP = lib.mkForce false;
    interfaces = lib.mkForce {};
    networkmanager.enable = lib.mkForce false;
  };
  isoImage = {
    edition = lib.mkForce "minimal";
    isoName = lib.mkForce "${config.isoImage.isoBaseName}-${targetSystem.config.networking.hostName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
    makeEfiBootable = true;
    makeUsbBootable = true;
    squashfsCompression = "zstd -Xcompression-level 19";
  };
  system.stateVersion = "25.05";
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig = {
      ExecStart = ["" installerFailsafe];
      Restart = "no";
      StandardInput = "null";
    };
  };
}
