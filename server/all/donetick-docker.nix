# donetick
# sudo mkdir /var/lib/donetick/data
# sudo chown -R 1000:1000 /var/lib/donetick
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.donetick.ip} ${infra.donetick.hostname} ${infra.donetick.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.donetick.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.donetick.fqdn}" = {
      listenAddresses = [infra.donetick.ip];
      extraConfig = ''import intraproxy ${toString infra.donetick.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        donetick = {
          image = "donetick/donetick";
          ports = ["${infra.localhost.ip}:${toString infra.donetick.localbind.port.http}:2021"];
          volumes = [
            "/var/lib/donetick/data:/donetick-data"
          ];
          environment = {
            TZ = "Europe/Berlin";
            DT_SQLITE_PATH = "/donetick-data/donetick.db";
            DT_NAME = infra.donetick.fqdn;
            DT_IS_DONE_TICK_DOT_COM = infra.false;
            DT_IS_USER_CREATION_DISABLED = infra.false;
            DT_DATABASE_TYPE = "sqlite";
            DT_DATABASE_MIGRATION = infra.true;
            DT_JWT_SECRET = "KWg-GVfGhef7DMeOEScSg2mSAtR7184kr2fAu8FD42o=";
            DT_JWT_SESSION_TIME = "168h";
            DT_JWT_MAX_REFRESH = "168h";
            DT_SERVER_PORT = "2021";
            DT_SERVER_READ_TIMEOUT = "2s";
            DT_SERVER_WRITE_TIMEOUT = "1s";
            DT_SERVER_RATE_PERIOD = "60s";
            DT_SERVER_RATE_LIMIT = "300";
            DT_SERVER_CORS_ALLOW_ORIGINS = "${infra.donetick.url},http://localhost:5173,http://localhost:7926,https://localhost,capacitor://localhost";
            DT_SERVER_SERVE_FRONTEND = infra.true;
            DT_SCHEDULER_JOBS_DUE_JOB = "30m";
            DT_SCHEDULER_JOBS_OVERDUE_JOB = "3h";
            DT_SCHEDULER_JOBS_PRE_DUE_JOB = "3h";
            # DT_TELEGRAM_TOKEN=
            # DT_PUSHOVER_TOKEN=
            # DT_EMAIL_HOST=
            # DT_EMAIL_PORT=
            # DT_EMAIL_KEY=
            # DT_EMAIL_EMAIL=
            # DT_EMAIL_APP_HOST=
            # DT_OAUTH2_CLIENT_ID=
            # DT_OAUTH2_CLIENT_SECRET=
            # DT_OAUTH2_AUTH_URL=
            # DT_OAUTH2_TOKEN_URL=
            # DT_OAUTH2_USER_INFO_URL=
            # DT_OAUTH2_REDIRECT_URL=
            # DT_STORAGE_MAX_USER_STORAGE=
            # DT_STORAGE_MAX_FILE_SIZE=
            # DT_STORAGE_BUCKET_NAME=
            # DT_STORAGE_REGION=
            # DT_STORAGE_BASE_PATH=
            # DT_STORAGE_ACCESS_KEY=
            # DT_STORAGE_SECRET_KEY=
            # DT_STORAGE_ENDPOINT=
          };
        };
      };
    };
  };
}
