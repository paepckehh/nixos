{
  config,
  pkgs,
  lib,
  ...
}: let
  infra = (import ./base.nix).infra {
    site = {
      id = 50;
      name = "ttt";
      displayName = "ttt GmbH";
      domain.extern = "ttt.de";
    };
  };
in {infra = infra;}
