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
  networking.extraHosts = "${infra.sso.ip} ${infra.sso.hostname} ${infra.sso.fqdn}";

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      "authelia-jwt-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-jwt.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
      "authelia-key-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-key.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
      "authelia-session-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-session.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups."authelia-${infra.sso.site}" = {};
    users = {
      "authelia-${infra.sso.site}" = {
        group = "authelia-${infra.sso.site}";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh ssoentication
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    authelia.instances = {
      "${infra.sso.site}" = {
        enable = true;
        secrets = {
          jwtSecretFile = config.age.secrets."authelia-jwt-${infra.sso.site}".path;
          storageEncryptionKeyFile = config.age.secrets."authelia-key-${infra.sso.site}".path;
          sessionSecretFile = config.age.secrets."authelia-session-${infra.sso.site}".path;
        };
        settings = {
          server = {
            address = "tcp4://${infra.localhost.ip}:${toString infra.sso.localbind.port.http}";
            endpoints.authz.forward-auth.implementation = "ForwardAuth";
          };
          theme = "dark";
          log = {
            level = "debug";
            format = "text";
          };
          authentication_backend = {
            refresh_interval = "1m";
            password_reset.disable = true;
            password_change.disable = true;
            ldap = {
              implementation = infra.ldap.package;
              address = infra.ldap.uri;
              tls.skip_verify = true;
              base_dn = infra.ldap.base;
              user = infra.ldap.bind.dn;
              password = infra.ldap.bind.pwd;
            };
          };
          access_control = {
            default_policy = "deny";
            rules = [
              {
                domain = ["${infra.sso.fqdn}"];
                policy = "bypass";
              }
              {
                domain = ["*.${infra.sso.fqdn}"];
                policy = "two_factor";
              }
            ];
          };
          session = {
            name = "authelia_session";
            same_site = "lax";
            inactivity = "5m";
            expiration = "7d";
            remember_me = "3M";
            redis.host = "/run/redis-authelia-${infra.sso.site}/redis.sock";
            cookies = [
              {
                domain = infra.domain.user;
                authelia_url = infra.sso.url;
                default_redirection_url = infra.portal.url;
                name = "authelia_session";
                same_site = "lax";
                inactivity = "1h";
                expiration = "7d";
                remember_me = "3M";
              }
            ];
          };
          # session = {
          #  domain = infra.domain.user;
          #  same_site = "lax";
          #  inactivity = "5m";
          #  expiration = "1h";
          #  remember_me = "38d";
          #  redis.host = "/run/redis-authelia-${infra.sso.site}/redis.sock";
          # };
          regulation = {
            max_retries = 5;
            find_time = "5m";
            ban_time = "15m";
          };
          storage = {
            local.path = "/var/lib/authelia-${infra.sso.site}/db.sqlite3";
          };
          notifier = {
            disable_startup_check = true;
            smtp = {
              address = infra.smtp.uri;
              sender = infra.admin.email;
              subject = "[DebiCloud] [Business] [Anmeldung] [SSO]";
              disable_require_tls = true;
              disable_html_emails = true;
            };
          };
          telemetry = {
            metrics = {
              enabled = false;
              address = "tcp://localhost:9102/metrics";
            };
          };
          webauthn = {
            disable = false;
            enable_passkey_login = true;
            display_name = "Authelia";
            attestation_conveyance_preference = "none";
            timeout = "120 seconds";
            metadata.enabled = false;
            selection_criteria = {
              attachment = "cross-platform";
              discoverability = "preferred";
              user_verification = "preferred";
            };
          };
          # identity_providers = {
          #  oidc = {
          #    clients = [
          #      {
          #        client_id = "nextcloud";
          #        client_name = "NextCloud";
          #        client_secret = "insecure_next_secret";
          #        public = "false";
          #        authorization_policy = "two_factor";
          #        require_pkce = true;
          #        pkce_challenge_method = "S256";
          #        redirect_uris = ["https://cloud.dbt.corp/apps/user_oidc/code"];
          #        scopes = ["openid" "profile" "email" "groups"];
          #        response_types = ["code"];
          #        grant_types = ["authorization_code"];
          #        access_token_signed_response_alg = "none";
          #        userinfo_signed_response_alg = "none";
          #        token_endpoint_auth_method = "client_secret_post";
          #      }
          #    ];
          #  };
          # };
        };
      };
    };
    redis.servers."authelia-${infra.sso.site}" = {
      enable = true;
      group = "authelia-${infra.sso.site}";
      user = "authelia-${infra.sso.site}";
      port = 0;
      unixSocket = "/run/redis-authelia-${infra.sso.site}/redis.sock";
      unixSocketPerm = 600;
    };
    caddy.virtualHosts."${infra.sso.fqdn}" = {
      listenAddresses = [infra.sso.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.sso.localbind.port.http}
        @not_intranet { not remote_ip ${infra.sso.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
