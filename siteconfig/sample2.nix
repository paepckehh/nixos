{
  config,
  pkgs,
  lib,
  ...
}: let
  infra = (import ./base.nix).infra {
    site = {
      id = 23;
      name = "dss";
      displayName = "CDE  GmbH";
      domain.extern = "cde.de";
    };
  };
in {infra = infra;}
