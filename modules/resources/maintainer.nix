{
  pkgs ? import ./. {config.allowBroken = true;},
  maintainer ? "dawidd6",
}:
with pkgs.lib; let
  mypkgs =
    filterAttrs (
      name: value:
        (builtins.tryEval value).success
        && elem maintainers.${maintainer} (value.meta.maintainers or [])
    )
    pkgs;
in {maintained = pkgs.lib.mapAttrs (n: v: (v?pname ? v?name)) mypkgs;}
