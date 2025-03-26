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
          type = lib.mkForce "postgresql";
          target = lib.mkForce "postgres://blocky@/blocky";
        };
      };
    };
    postgresql = {
      enable = true;
      enableTCPIP = false;
      package = pkgs.postgresql_17;
      ensureDatabases = ["blocky"];
      ensureUsers = [
        {
          name = "blocky";
          ensureDBOwnership = true;
        }
      ];
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
