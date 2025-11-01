{
  config,
  pkgs,
  lib,
  ...
}: let
  infra = (import ./base.nix).infra {
    site = {
      id = 10;
      name = "example";
      displayName = "Example ltd";
      domain.extern = "example.com";
    };
  };
in {infra = infra;}
