{pkgs, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        queryLog = {
          type = "timescale";
          target = "postgres://blocky@127.0.0.1:5432/db_blocky";
          logRetentionDays = 7;
          creationAttempts = 5;
          creationCooldown = "5s";
          flushInterval = "60s";
        };
      };
    };
    postgresql = {
      enable = true;
      enableTCPIP = true;
      package = pkgs.postgresql_17;
      extraPlugins = [pkgs.postgresql17Packages.timescaledb];
      ensureDatabases = ["blocky"];
      ensureUsers = {
        blocky = {
          name = "blocky";
          ensureDBOwnership = true;
        };
      };
      settings = {
        port = 5432;
        shared_preload_libraries = "timescaledb";
      };
    };
  };
}
