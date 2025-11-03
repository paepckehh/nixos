{
  config,
  pkgs,
  lib,
  ...
}: let
  infra = (import ./base.nix).infra {
    site = {
      id = 23;
      name = "pvz";
      displayName = "PVZ Pressevertriebszentrale GmbH & Co. KG";
      domain.extern = "pvz.digital";
    };
  };
in {infra = infra;}
