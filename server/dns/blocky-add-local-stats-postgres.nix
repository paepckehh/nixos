{pkgs, ...}: {
  # dashboard grafana https://0xerr0r.github.io/blocky/latest/blocky-query-grafana-postgres.json
  # logfile analysis via pgweb
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [pgweb];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        queryLog = {
          type = "postgresql";
          target = "postgres://blocky:start@/db_blocky";
          logRetentionDays = 180;
          creationAttempts = 5;
          creationCooldown = "5s";
          flushInterval = "10s";
        };
      };
    };
    postgresql = {
      enable = true;
      enableTCPIP = true;
      package = pkgs.postgresql_17;
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE USER blocky WITH PASSWORD 'start';
        CREATE DATABASE db_blocky;
        GRANT ALL PRIVILEGES ON DATABASE db_blocky TO blocky;
        GRANT ALL ON SCHEMA public TO blocky;
        ALTER DATABASE db_blocky OWNER TO blocky;
      '';
    };
    grafana = {
      enable = true;
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Postgres";
            type = "postgres";
            # url = "/run/postgresql";
            url = "localhost:5432";
            user = "blocky";
            secureJsonData.password = "start";
            jsonData = {
              database = "db_blocky";
              sslmode = "disable";
            };
          }
        ];
      };
    };
  };
}
