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
        infra.cache.url
        infra.cache.up.url
      ];
      substituters = lib.mkForce [
        infra.cache.url
        infra.cache.up.url
      ];
      trusted-public-keys = lib.mkForce [
        infra.cache.key.pub
        infra.cache.up.pub
      ];
    };
  };
}
