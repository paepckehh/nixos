{
  config,
  lib,
  pkgs,
  ...
}: let
  nixos-boot-src = pkgs.fetchFromGitHub {
    owner = "Melkor333";
    repo = "nixos-boot";
    rev = "main";
    sha256 = "sha256-Dj8LhVTOrHEnqgONbCEKIEyglO7zQej+KS08faO9NJk=";
  };
in {
  imports = ["${nixos-boot-src}/modules.nix"];
  nixos-boot = {
    enable = true;
  };
}
