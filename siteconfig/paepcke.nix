{
  config,
  pkgs,
  lib,
  ...
}: let
  infra = (import ./base.nix).infra {
    site = {
      id = 50;
      name = "home";
      DisplayName = "Home Paepcke";
      domain.extern = "paepcke.de";
    };
  };
in {infra = infra;}
