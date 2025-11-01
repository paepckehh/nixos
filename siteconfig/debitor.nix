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
      displayName = "Debitor Inkasso GmbH";
      domain.extern = "debitor.de";
    };
  };
in {infra = infra;}
