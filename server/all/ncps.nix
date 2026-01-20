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
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.cache.ip} ${infra.cache.hostname} ${infra.cache.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.cache.ip}/32";}];

  #################
  #-=# IMPORTS #=-#
  #################
  imports = [../../client/addCache.nix];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.cache.fqdn}" = {
      listenAddresses = [infra.cache.ip];
      extraConfig = ''import intraproxy ${toString infra.cache.localbind.port.http}'';
    };
    ncps = {
      enable = true;
      prometheus.enable = false;
      logLevel = "trace"; # "trace", "debug", "info", "warn", "error", "fatal", "panic"
      server.addr = "${infra.localhost.ip}:${toString infra.cache.localbind.port.http}";
      cache = {
        hostName = infra.cache.hostname;
        maxSize = infra.cache.size;
        allowPutVerb = lib.mkForce false;
        allowDeleteVerb = lib.mkForce false;
        lru.schedule = "10 10 * * *"; # cleanup cache daily 10:10
      };
      upstream = {
        caches = lib.mkForce [
          "https://cache.nixos.org"
        ];
        publicKeys = lib.mkForce [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };
  };
}
