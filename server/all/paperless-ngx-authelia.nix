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
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.paperless.ip} ${infra.paperless.hostname} ${infra.paperless.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.paperless.ip}/32";}];

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

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.paperless.fqdn}" = {
      listenAddresses = [infra.paperless.ip];
      extraConfig = ''import intraproxy ${toString infra.paperless.localbind.port.http}'';
    };
    paperless = {
      enable = true;
      address = infra.localhost.ip;
      port = infra.paperless.localbind.port.http;
      passwordFile = config.age.secrets.paperless.path;
      configureTika = true;
      database.createLocally = true;
      domain = infra.paperless.fqdn;
      exporter.enable = false;
      settings = {
        PAPERLESS_ADMIN_EMAIL = infra.admin.email;
        PAPERLESS_ACCOUNT_ALLOW_SIGNUPS = true;
        PAPERLESS_ACCOUNT_EMAIL_VERIFICATION = false;
        PAPERLESS_ACCOUNT_DEFAULT_GROUPS = "user"; # XXX create and configure group user !
        PAPERLESS_TASK_WORKER = 2;
        PAPERLESS_THREADS_PER_WORKER = 6;
        PAPERLESS_TIME_ZONE = infra.locale.tz;
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
        # PAPERLESS_ENABLE_HTTP_REMOTE_USER = true;
        # PAPERLESS_HTTP_REMOTE_USER_HEADER_NAME = "HTTP_REMOTE_USER";
        # PAPERLESS_LOGOUT_REDIRECT_URL = "${infra.sso.url}/logout";
        # PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
        # PAPERLESS_SOCIALACCOUNT_PROVIDERS = ''{"openid_connect":{"APPS": [{"provider_id":"${infra.sso.app}","name":"${infra.sso.app}","client_id":"${infra.paperless.app}","secret":"insecure_secret","settings":{"server_url":"${infra.sso.oidc.discoveryUri}"}}]}}'';
      };
    };
  };
}
# PAPERLESS_SOCIALACCOUNT_PROVIDERS = ''
#  {
#    "openid_connect": {
#      "SCOPE": ["openid", "profile", "email"],
#      "OAUTH_PKCE_ENABLED": true,
#      "APPS": [
#        {
#          "provider_id": "${infra.sso.app}",
#          "name": "${infra.sso.app}",
#          "client_id": "${infra.paperless.app}",
#          "secret": "insecure_secret",
#          "settings": {
#            "server_url": "${infra.paperless.url}",
#            "token_auth_method": "${infra.sso.oidc.auth.basic}"
#          }
#        }
#      ]
#    }
#  }'';
#        PAPERLESS_SOCIALACCOUNT_PROVIDERS = ''
#          {
#            "openid_connect": {
#              "APPS": [
#                {
#                  "provider_id": "${infra.sso.app}",
#                  "name": "${infra.sso.app}",
#                  "client_id": "${infra.paperless.app}",
#                  "secret": "insecure_secret",
#                  "settings": {
#                    "server_url": "${infra.sso.url}",
#                    "token_auth_method": "${infra.sso.oidc.auth.basic}"
#                  }
#                }
#              ]
#            }
#          }'';
#      };

