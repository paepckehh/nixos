{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      # libnfc-nci
      # libnfc
      # neard
      pcsc-tools
      # pcsclite
      # vsmartcard-vpcd
      # vsmartcard-pcsc-relay
    ];
  };

  ##############
  #-=# BOOT #=-#
  ##############
  boot.blacklistedKernelModules = infra.kernel.blacklist ++ ["pn533" "pn533_usb" "nfc"];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.pcscd = {
    enable = lib.mkForce true;
    # plugins = with pkgs; [ccid acsccid libacr38u scmccid ifdnfc pcsc-cyberjack pcsc-scm-scl011];
    plugins = with pkgs; [ccid acsccid libacr38u scmccid pcsc-cyberjack pcsc-scm-scl011];
  };
}
