{
  config,
  pkgs,
  lib,
  ...
}: let
  infra = (import ./base.nix).infra {
    site = {
      id = 23;
      name = "xzy";
      displayName = "XYZ  GmbH";
      domain.extern = "zyx.de";
    };
  };
in {infra = infra;}
