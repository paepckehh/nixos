{
  config,
  pkgs,
  lib,
  ...
}: let
  infra = (import ./base.nix).infra {
    site = {
      id = 50;
      name = "dbt";
      displayName = "zyx GmbH";
      domain.extern = "xyz.de";
    };
  };
in {infra = infra;}
