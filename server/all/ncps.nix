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
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.cache.ip}/32";}];

  #################
  #-=# IMPORTS #=-#
  #################
  imports = [../../client/addCache.nix];

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      ncps = {
        file = ../../modules/resources/ncps.age;
        owner = "ncps";
      };
    };
  };

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
      analytics.reporting.enable = lib.mkForce false;
      logLevel = "warn"; # "trace", "debug", "info", "warn", "error", "fatal", "panic"
      prometheus.enable = lib.mkForce false;
      server.addr = "${infra.localhost.ip}:${toString infra.cache.localbind.port.http}";
      openTelemetry.enable = lib.mkForce false;
      netrcFile = null;
      cache = {
        allowPutVerb = lib.mkForce false;
        allowDeleteVerb = lib.mkForce false;
        hostName = infra.cache.hostname;
        lru.schedule = "10 10 * * *"; # cleanup cache daily 10:10
        maxSize = infra.cache.size;
        secretKeyPath = null;
        signNarinfo = lib.mkForce true;
        storage.local = lib.mkForce infra.cache.storage;
        upstream = {
          dialerTimeout = lib.mkForce "4m";
          responseHeaderTimeout = lib.mkForce "30s";
          urls = lib.mkForce ["https://cache.nixos.org"];
          publicKeys = lib.mkForce ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
        };
      };
    };
  };
}
