{
  config,
  pkgs,
  ...
}: {
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        shifter = {
          image = "tobysuch/shifter";
          ports = ["0.0.0.0:4002:80"];
          volumes = ["/var/shifter:/data"];
          environment = {
            "DJANGO_ALLOWED_HOSTS" = "localhost 127.0.0.1";
            "DJANGO_SUPERUSER_EMAIL" = "it@me.lan";
            "DJANGO_SUPERUSER_PASSWORD" = "start";
            "DJANGO_LOG_LEVEL" = "INFO";
            "DJANGO_LOG_LOCATION" = "/var/shifter/log";
            "DEBUG" = "0";
            "SECRET_KEY" = "mkinmfrivreERo4fm4oim3f3";
            "CSRF_TRUSTED_ORIGINS" = "http://localhost";
            "CLIENT_MAX_BODY_SIZE" = "1G";
            "DATABASE" = "sqlite";
            "EXPIRED_FILE_CLEANUP_SCHEDULE" = "*/15 * * * *  ";
            "SHIFTER_FULL_DOMAIN" = "http://localhost";
            "TIMEZONE" = "UTC";
          };
        };
      };
    };
  };
}
