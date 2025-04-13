{
  lib,
  pkgs,
  ...
}: let
  ##############
  #-=# INFO #=-#
  ##############
  # set blocky.query-stats.local = true to host postgres and grafana locally
  # => default web interface stats_log   http://localhost:8081
  # => default web interface grafana     http://localhost:3000  (initial user/password = admin/admin)
  # => manually import resources/blocky-query-grafana-postgres.json (!) (https://0xerr0r.github.io/blocky/latest/blocky-query-grafana-postgres.json)
  ################
  #-=# CONFIG #=-#
  ################
  blocky.query-stats = {
    enabled = true;
    local = true;
    host = "localhost"; # localhost => install local postgresql, grafana, pgweb
    user = "blocky";
    password = "start";
    port = "5432";
    db = "db_blocky";
  };
in
  lib.mkIf blocky.query-stats.enabled {
    ##################
    #-=# SERVICES #=-#
    ##################
    services = {
      blocky = {
        settings = {
          queryLog = {
            type = "postgresql";
            # target = "postgres://${blocky.query-stats.user}:${blocky.query-stats.password}@/${blocky.query-stats.db}"; # bind via unix_socket (supress host/port)
            target = "postgres://${blocky.query-stats.user}:${blocky.query-stats.password}@${blocky.query-stats.host}/${blocky.query-stats.db}";
            logRetentionDays = 180;
            creationAttempts = 5;
            creationCooldown = "5s";
            flushInterval = "15s";
          };
        };
      };
      postgresql = {
        enable = blocky.query-stats.local;
        enableTCPIP = true;
        package = pkgs.postgresql_17;
        initialScript = pkgs.writeText "backend-initScript" ''
          CREATE USER blocky WITH PASSWORD 'start';
          CREATE DATABASE ${blocky.query-stats.db};
          GRANT ALL PRIVILEGES ON DATABASE ${blocky.query-stats.db} TO ${blocky.query-stats.user};
          GRANT ALL ON SCHEMA public TO ${blocky.query-stats.user};
          ALTER DATABASE ${blocky.query-stats.db} OWNER TO ${blocky.query-stats.user};
        '';
      };
      grafana = {
        enable = blocky.query-stats.local;
        provision = {
          enable = true;
          dashboards.settings.providers = lib.mkForce [
            {
              name = "pre-configured-local-dashboards";
              options.path = "/etc/grafana-dashboards";
            }
          ];
          datasources.settings.datasources = [
            {
              name = "Postgres";
              type = "postgres";
              url = "${blocky.query-stats.host}:${blocky.query-stats.port}";
              user = "blocky";
              secureJsonData.password = "${blocky.query-stats.password}";
              jsonData = {
                database = "${blocky.query-stats.db}";
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
    environment = {
      systemPackages = with pkgs; [pgweb];
      # XXX debug: automatic import fails, needs manual import, see info section
      # etc."grafana-dashboards/blocky-query-grafana-postgres.json" = {
      #  source = "/etc/nixos/server/dns/resources/blocky-query-grafana-postgres.json";
      #  group = "grafana";
      #  user = "grafana";
      # };
    };

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
          ];
        };
        environment = {
          PGWEB_DATABASE_URL = "postgres://${blocky.query-stats.user}:${blocky.query-stats.password}@${blocky.query-stats.host}:${blocky.query-stats.port}/${blocky.query-stats.db}";
          PGWEB_AUTH_LOCK_SESSION = "1";
        };
      };
    };
  }
