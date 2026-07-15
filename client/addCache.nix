# nixos/cache => services.ncps nixos binary cache (build/sign/cache)
# generated pubkey url = "https://${infra.cache.fqdn}/pubkey"
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  #############
  #-=# NIX #=-#
  #############
  nix = {
    settings = {
      require-sigs = lib.mkForce true;
      allowed-uris = lib.mkForce [
        infra.nix.cache.local.url
        # infra.nix.cache.external2.url
        # infra.nix.cache.external1.url
        # infra.nix.cache.external.url
        # infra.nix.cache.internet.url
      ];
      substituters = lib.mkForce [
        infra.nix.cache.local.url
        # infra.nix.cache.external2.url
        # infra.nix.cache.external1.url
        # infra.nix.cache.external.url
        # infra.nix.cache.internet.url
      ];
      trusted-public-keys = lib.mkForce [
        infra.nix.cache.local.key
        # infra.nix.cache.external2.key
        # infra.nix.cache.external1.key
        # infra.nix.cache.external.key
        # infra.nix.cache.internet.key
      ];
    };
  };
}
