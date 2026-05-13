# paperless paperless-ngx
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
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets.paperless = {
      file = ../../modules/resources/paperless.age;
      owner = "paperless";
      group = "paperless";
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.paperless = {};
    users = {
      paperless = {
        group = "paperless";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.paperless.ip} ${infra.paperless.hostname} ${infra.paperless.fqdn}";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.paperless.fqdn}" = {
      listenAddresses = [infra.paperless.ip];
      extraConfig = ''import intraauthproxy ${toString infra.paperless.localbind.port.http}'';
    };
    paperless = {
      enable = true;
      address = infra.localhost.ip;
      port = infra.paperless.localbind.port.http;
      passwordFile = config.age.secrets.paperless.path;
      configureTika = true;
      database.createLocally = true;
      domain = infra.paperless.fqdn;
      exporter.enable = true;
      settings = {
        PAPERLESS_ENABLE_HTTP_REMOTE_USER = true;
        PAPERLESS_HTTP_REMOTE_USER_HEADER_NAME = "REMOTE-USER";
        PAPERLESS_LOGOUT_REDIRECT_URL = "${infra.sso.url}/logout";
        PAPERLESS_ADMIN_EMAIL = infra.admin.email;
        PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = true;
        PAPERLESS_ACCOUNT_EMAIL_VERIFICATION = false;
        PAPERLESS_ACCOUNT_DEFAULT_GROUPS = "user";
        PAPERLESS_TASK_WORKER = 2;
        PAPERLESS_THREADS_PER_WORKER = 6;
        PAPERLESS_TIME_ZONE = infra.locale.tz;
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };
  };
}
