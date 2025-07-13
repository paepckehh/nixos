{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # environment.systemPackages = with pkgs; [podman-tui podman-compose docker docker-compose compose2nix];

  ###############
  # NETWORKING #
  ##############
  networking.extraHosts = ''127.0.0.1 postgres'';

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        timeoff = {
          image = "ashless/timeoff-alien";
          ports = ["3000:3000"];
          hostname = "timeoff";
          extraOptions = ["--network=host"];
          environment = {
            APP_PORT = "3000";
            BRANDING_URL = "http://localhost:3000";
            DATABASE_URL = "postgresql://timeoff-user:timeoff-pass@localhost:5432/timeoff-db";
            DB_DIALECT = "postgres";
            DB_HOST = "postgres";
            DB_PORT = "5432";
            DB_SSL_REQUIRE = "false";
            DOCKER_DB_URL = "postgresql://timeoff-user:timeoff-pass@postgres:5432/timeoff-db";
            HEADER_TITLE = "Urlaubs-Management";
            OPTION_ALLOW_NEW_REGISTRATIONS = "true";
            PUBLIC_BANNER_MESSAGE = "debby holiday planner";
            PUBLIC_MESSAGE_BG = "#000000";
            PUBLIC_MESSAGE_FONT = "#ffffff";
            SEND_EMAIL = "false";
            SESSION_SECRET = "cmdskmvkdfnk2e143r2ef1cedwre";
            SHOW_PUBLIC_BANNER = "false";
            USE_SSL = "false";
          };
        };
        postgres = {
          image = "postgres:15-alpine";
          ports = ["5432:5432"];
          hostname = "postgres";
          extraOptions = ["--network=host"];
          environment = {
            POSTGRES_DB = "timeoff-db";
            POSTGRES_USER = "timeoff-user";
            POSTGRES_PASSWORD = "timeoff-pass";
          };
          volumes = [
            "postgres_data:/var/lib/postgresql/data"
          ];
        };
      };
    };
  };
}
