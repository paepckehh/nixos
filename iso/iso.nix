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
      dosfstools
      e2fsprogs
      gawk
      nixos-install-tools
      util-linux
      config.nix.package
    ];
    text = ''
      set -euo pipefail
      echo "-=!*** [ NIXOS-AUTO-SETUP ] ***!=-"
      echo ""
      echo "[NIX-AUTO] Setting up disks..."
      for i in $(lsblk -pln -o NAME,TYPE | grep disk | awk '{ print $1 }'); do
        if [[ "$i" == "/dev/fd0" ]]; then
          echo "$i is a floppy, skipping..."
          continue
        fi
        if grep -ql "^$i" <(mount); then
          echo "[NIX-AUTO] Disk: $i is in use -> skip"
        else
          DEVICE_MAIN="$i"
          break
        fi
      done

      if [[ -z "$DEVICE_MAIN" ]]; then
        echo "[NIX-AUTO][ERROR] No usable disk found on this machine!"
        exit 1
      else
        echo "[NIX-AUTO] Disk: $DEVICE_MAIN will be erased."
        echo "[NIX-AUTO] You have 5 seconds to cancel this operation!"
        sleep 7
      fi

      DISKO_DEVICE_MAIN=''${DEVICE_MAIN#"/dev/"} ${targetSystem.config.system.build.diskoScript} 2> /dev/null

      echo "[NIX-AUTO] Installing NixOS now."
      nixos-install --no-channel-copy --no-root-password --option substituters "" --system ${targetSystem.config.system.build.toplevel}

      echo "[NIX-AUTO] Installation Done! 
      echo "[NIX-AUTO] Rebooting Now!
      echo "[NIX-AUTO] You have 5 seconds to cancel this operation!"
      sleep 7
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
     squashfsCompression = "zstd -Xcompression-level 18"; 
  }

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
