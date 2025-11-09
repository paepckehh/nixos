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
  # https://${infra.cache.fqdn}/pubkey" to fetch generated key
  nix = {
    settings = {
      http2 = lib.mkForce true;
      require-sigs = lib.mkForce true;
      preallocate-contents = true;
      allowed-uris = [
        "https://${infra.cache.fqdn}"
      ];
      substituters = [
        "https://${infra.cache.fqdn}"
      ];
      trusted-public-keys = [
        cache:aFde6/c1Vz93N1XGGrvt/7NlUNdAyV35CgBUXKzyhyU=
      ];
    };
  };
}
