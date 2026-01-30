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
      displayName = "ABC GmbH & Co. KG";
      domain.extern = "abc.digital";
    };
  };
in {infra = infra;}
