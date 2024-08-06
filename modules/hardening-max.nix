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
    ./hardening-full.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    memoryAllocator.provider = lib.mkForce "scudo"; # alloc hardening
    variables = {
      SCUDO_OPTIONS = lib.mkForce "ZeroContents=1";
    };
  };
}
