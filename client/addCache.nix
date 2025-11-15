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
      http2 = lib.mkForce true;
      require-sigs = lib.mkForce true;
      preallocate-contents = true;
      allowed-uris = lib.mkForce [
        infra.cache.url
      ];
      substituters = lib.mkForce [
        infra.cache.url
      ];
      trusted-public-keys = lib.mkForce [
        infra.cache.key.pub
      ];
    };
  };
}
