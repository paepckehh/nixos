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
      gum
      dosfstools
      e2fsprogs
      gawk
      nixos-install-tools
      util-linux
      config.nix.package
    ];
    text = ''
      #!/bin/sh
      echo ""
      echo "-=!*** [ NIXOS-AUTO-SETUP ] ***!=-"
      echo ""
      echo "[NIX-AUTO] Lets try to find a usable disk."
      echo "[NIX-AUTO] This is your current storage device list."
      echo "############################################################"
      lsblk
      echo "############################################################"
      DEVICE_MAIN=""
      for i in $(lsblk -pln -o NAME,TYPE | grep disk | awk '{ print $1 }'); do
        echo "[NIX-AUTO] Testing Disk: $i"
        case $i in
        /dev/sd*)
          echo "[NIX-AUTO] Found Disk: i$ - This may be your usb installation boot device, skip it for now."
          continue
          ;;
        /dev/zram*)
          echo "[NIX-AUTO] Found Disk: i$ - This is your swap device, skip it."
          continue
          ;;
        *)
          echo "[NIX-AUTO] Found Disk: $i"
          DEVICE_MAIN="$i"
          break
          ;;
        esac
      done
      case $DEVICE_MAIN in
      "")
        echo "[NIX-AUTO][ERROR] Unable to find a valid secure target disk, please enter it manually."
        echo "######################################################################################"
        lsblk
        echo "######################################################################################"
        DEVICE_MAIN=$(gum choose -- $(lsblk -pln -o NAME,TYPE | grep disk | awk '{ print $1 }'))
        echo "[NIX-AUTO] New Manually Selected Active Disk: $DEVICE_MAIN"
        ;;
      *)
        echo "[NIX-AUTO] Selected Active Disk: $DEVICE_MAIN"
        ;;
      esac
      echo "[NIX-AUTO] Disk: $DEVICE_MAIN will be erased."
      wipefs --all --force "$DEVICE_MAIN"
      DISKO_DEVICE_MAIN=''${DEVICE_MAIN#"/dev/"} ${targetSystem.config.system.build.diskoScript}
      echo "[NIX-AUTO] Installing NixOS now."
      nixos-generate-config --force --root /mnt
      nixos-install --keep-going --no-root-password --cores 0 --option substituters "" --system ${targetSystem.config.system.build.toplevel}
      echo "[NIX-AUTO] Installation Done!
      echo "[NIX-AUTO] Setup Custom /etc/nixos
      cd /mnt/etc
      echo "[NIX-AUTO] Installation Done!
      echo "[NIX-AUTO] Rebooting Now!
      reboot
    '';
  };
in {
  imports = [
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
    (modulesPath + "/profiles/all-hardware.nix")
  ];
  boot.kernelParams = ["systemd.unit=getty.target"];
  console = {
    earlySetup = true;
    font = "ter-v16n";
    packages = [pkgs.terminus_font];
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
