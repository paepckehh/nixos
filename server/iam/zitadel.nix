{
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    postgresql = {
      enable = true;
      enableTCPIP = true;
      package = pkgs.postgresql_17;
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE USER zitadel WITH PASSWORD 'start';
        CREATE DATABASE zitadel;
        GRANT ALL PRIVILEGES ON DATABASE zitadel TO zitadel;
        GRANT ALL ON SCHEMA public TO zitadel;
        ALTER DATABASE zitadel OWNER TO zitadel;
      '';
    };
    zitadel = {
      enable = true;
      services.zitadel.settings = {
        Port = 8081;
        Database.postgres = {
          Host = "127.0.0.1";
          Port = "${config.services.postgresql.settings.port}";
          Database = "zitadel";
          MaxOpenConns = "25";
          MaxConnLifetime = "1h";
          MaxConnIdleTime = "5m";
          User = {
            Username = "zitadel";
            Password = "start";
            SSL.Mode = "disable";
          };
          Admin = {
            Username = "postgres";
            Password = "postgres";
            SSL.Mode = "disable";
          };
        };
      };
    };
  };
}
