{pkgs, ...}: {
  # dashboard grafana https://0xerr0r.github.io/blocky/latest/blocky-query-grafana-postgres.json
  # logfile analysis via pgweb http://localhost:8081

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

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [pgweb];

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    services.pgweb = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      description = "PGWEB Service";
      serviceConfig = {
        ExecStart = "${pkgs.pgweb}/bin/pgweb";
        KillMode = "process";
        Restart = "always";
        DynamicUser = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
      environment = {
        PGWEB_DATABASE_URL = "postgres://localhost:5432/blocky";
        PGWEB_AUTH_USER = "blocky";
        PGWEB_AUTH_PASS = "start";
      };
    };
  };
}
