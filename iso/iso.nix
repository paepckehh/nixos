{
  config,
  pkgs,
  lib,
  modulesPath,
  targetSystem,
  ...
}: let
  installer = pkgs.writeShellApplication {
    name = "installer";
    runtimeInputs = with pkgs; [
      git
      dosfstools
      e2fsprogs
      gawk
      nixos-install-tools
      util-linux
      config.nix.package
    ];
    text = ''
      #!/bin/sh
      set -euo pipefail
      echo ""
      echo "-=!*** [ NIXOS-AUTO-SETUP ] ***!=-"
      echo ""
      echo "[NIX-AUTO] Lets try to find a usable disk."
      echo "[NIX-AUTO] This is your current storage device list."
      echo "############################################################"
      lsblk
      echo "############################################################"
      for i in $(lsblk -pln -o NAME,TYPE | grep disk | awk '{ print $1 }'); do
        echo "[NIX-AUTO] Testing Disk: $i"
        case $i in
        /dev/sda)
          echo "[NIX-AUTO] Disk /dev/sda is most likely your usb installation boot device, skip it for now."
          continue
          ;;
        /dev/sdb)
          echo "[NIX-AUTO] Disk /dev/sdb is most likely your usb installation boot device, skip it for now."
          continue
          ;;
        *)
          echo "[NIX-AUTO] Set New Active Disk: $i"
          DEVICE_MAIN="$i"
          break
          ;;
        esac
      done
      if [[ -z "$DEVICE_MAIN" ]]; then
        echo "[NIX-AUTO][ERROR] Unable to find a valid secure target disk, please enter it manually:  "
        read -r DEVICE_MAIN
      fi
      echo "[NIX-AUTO] Disk: $DEVICE_MAIN will be erased."
      wipefs --all --force "$DEVICE_MAIN"
      DISKO_DEVICE_MAIN=''${DEVICE_MAIN#"/dev/"} ${targetSystem.config.system.build.diskoScript}
      echo "############################################################"
      echo "############################################################"
      lsblk
      echo "############################################################"
      echo "############################################################"
      df -h
      echo "############################################################"
      echo "############################################################"
      sleep 10
      echo "[NIX-AUTO] Installing NixOS now."
      nixos-install --no-channel-copy --no-root-password --option substituters "" --system ${targetSystem.config.system.build.toplevel}
      echo "[NIX-AUTO] Installation Done!
      echo "[NIX-AUTO] Setup Custom /etc/nixos
      cd /mnt/etc
      git clone https://github.com/paepckehh/nixos
      echo "[NIX-AUTO] Installation Done!
      echo "[NIX-AUTO] Rebooting Now!
      reboot
    '';
  };
  installerFailsafe = pkgs.writeShellScript "failsafe" ''
    ${lib.getExe installer} || echo "ERROR: Installation failure!"
    sleep 3600
  '';
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
