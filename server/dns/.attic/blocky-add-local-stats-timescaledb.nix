{
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        queryLog = {
          type = lib.mkForce "timescale";
          target = lib.mkForce "postgres://blocky@/blocky";
        };
      };
    };
    postgresql = {
      enable = true;
      enableTCPIP = false;
      package = pkgs.postgresql_17;
      extensions = [pkgs.postgresql17Packages.timescaledb];
      ensureDatabases = ["blocky"];
      ensureUsers = [
        {
          name = "blocky";
          ensureDBOwnership = true;
          ensureClauses.superuser = true;
        }
      ];
      settings = {
        shared_preload_libraries = "timescaledb";
      };
    };
    grafana = {
      enable = true;
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Postgres";
            type = "postgres";
            url = "postgres://";
          }
        ];
      };
    };
  };
}
