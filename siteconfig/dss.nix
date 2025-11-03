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
      displayName = "Data-Service GmbH";
      domain.extern = "dssgmbh.de";
    };
  };
in {infra = infra;}
