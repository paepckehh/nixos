{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./hardening.nix
  ];

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_hardened;
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    allowSimultaneousMultithreading = lib.mkForce false;
    forcePageTableIsolation = lib.mkForce true;
  };
}
