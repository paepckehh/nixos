{
  lib,
  infra,
  ...
}:
lib.mkMerge [
  (import ../../lib/proxy.nix {
    inherit infra;
    name = "cache2";
  })
  {
    #################
    #-=# SYSTEMD #=-#
    #################
    systemd.tmpfiles.rules = ["d ${infra.cache2.storage} 0700 ncps ncps"];

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
      server.addr = "${infra.localhost.ip}:${toString infra.cache2.localbind.port.http}";
      openTelemetry.enable = lib.mkForce false;
      netrcFile = null;
      cache = {
        allowPutVerb = lib.mkForce false;
        allowDeleteVerb = lib.mkForce false;
        cdc.enabled = true;
        hostName = infra.cache2.hostname;
        lru.schedule = "02 00 * * *";
        maxSize = infra.cache2.cacheSize;
        # secretKeyPath = config.age.secrets.ncps.path;
        signNarinfo = lib.mkForce true;
        storage.local = lib.mkForce infra.cache2.storage;
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
