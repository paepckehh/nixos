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
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.wireless.networks = {
    "WIFI@DB" = {
      auth = null;
      authProtocols = "OWE";
      ssid = "WIFI@DB";
      psk = null;
      pskRaw = null;
      hidden = false;
    };
  };
}
