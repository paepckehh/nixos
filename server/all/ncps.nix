{
  config,
  lib,
  infra,
  ...
}:
lib.mkMerge [
  (import ../../lib/proxy.nix {
    inherit infra;
    name = "cache";
  })
  {
    #################
    #-=# SYSTEMD #=-#
    #################
    systemd.tmpfiles.rules = ["d ${infra.cache.storage} 0700 ncps ncps"];

    #############
    #-=# AGE #=-#
    #############
    age.secrets.ncps = {
      file = ../../modules/resources/ncps.age;
      owner = "ncps";
    };

    ##################
    #-=# SERVICES #=-#
    ##################
    services.ncps = {
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
        cdc.enabled = true;
        hostName = infra.cache.hostname;
        lru.schedule = "04 00 * * *";
        maxSize = infra.cache.cacheSize;
        secretKeyPath = config.age.secrets.ncps.path;
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
  }
]
