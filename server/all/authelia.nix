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

  # GENERATE RSA-KEY PAIR
  # mkdir -p /tmp/keys && cd /tmp/keys && nix-shell -p authelia --command 'authelia crypto pair rsa generate --bits 3072 --directory /tmp/keys'

  # GENERATE RANDOM STRING
  # nix-shell -p authelia --command 'authelia crypto rand --length 72 --charset rfc3986'
  # Random Value: B4gJOtTZnctp2BExOHh._N0MjYcghfMIvwGKauJ~XEJnaqBMEuN3Te8HRb15bMD5mWkVB5bb

  # GENERATE PBKDF2 HASHED
  # nix-shell -p authelia --command 'authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986'
  # Random Password: ph3qTDuGGwdRSA2I~ScU1PTXG8SPDUesrF2IETqYVTNl3D92P2d3EIL.TQ6Ex_-lbRi_9uL2
  # Digest: $pbkdf2-sha512$310000$OAmF.7KG6d6wms25SZWZug$XsyRQpD0/qUCkuakGEz4Hdr4MVx5Jq6w/qFbUs.vZ0qmTVyYSUX92PYn0Db5YbqcCjVhLfKUBHGD2wNC8xfDVw

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
      "authelia-storagekey-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-storagekey.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
      "authelia-session-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-session.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
      "authelia-oidc-hmac-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-oidc-hmac.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
      "authelia-oidc-issuer-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-oidc-issuer.age;
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

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services."authelia-${infra.sso.site}" = {
    after = ["socket.target"];
    wants = ["socket.target"];
    wantedBy = ["multi-user.target"];
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
          storageEncryptionKeyFile = config.age.secrets."authelia-storagekey-${infra.sso.site}".path;
          sessionSecretFile = config.age.secrets."authelia-session-${infra.sso.site}".path;
          oidcHmacSecretFile = config.age.secrets."authelia-oidc-hmac-${infra.sso.site}".path;
          oidcIssuerPrivateKeyFile = config.age.secrets."authelia-oidc-issuer-${infra.sso.site}".path;
        };
        settings = {
          theme = "dark";
          password_policy.zxcvbn.enabled = true;
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
          server = {
            address = "tcp4://${infra.localhost.ip}:${toString infra.sso.localbind.port.http}";
            # endpoints.authz.forward-auth.implementation = "ForwardAuth";
          };
          log = {
            level = "trace";
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
            display_name = "authelia";
            attestation_conveyance_preference = "none";
            timeout = "120 seconds";
            metadata.enabled = false;
            selection_criteria = {
              attachment = "cross-platform";
              discoverability = "preferred";
              user_verification = "preferred";
            };
          };
          definitions.user_attributes.is_nextcloud_admin.expression = ''"nextcloud-admins" in groups'';
          identity_providers.oidc = {
            claims_policies.nextcloud_userinfo.custom_claims.is_nextcloud_admin = {};
            scopes.nextcloud_userinfo.claims = "is_nextcloud_admin";
            clients = [
              {
                client_id = "nextcloud";
                client_name = "nextcloud";
                client_secret = "$pbkdf2-sha512$310000$c8p78n7pUMln0jzvd4aK4Q$JNRBzwAo0ek5qKn50cFzzvE9RXV88h1wJn5KGiHrD0YKtZaR/nCb2CJPOsKaPK0hjf.9yHxzQGZziziccp6Yng"; # 'insecure_secret'
                public = false;
                authorization_policy = "two_factor";
                require_pkce = true;
                pkce_challenge_method = "S256";
                claims_policy = "nextcloud_userinfo";
                redirect_uris = ["https://cloud.home.corp/apps/sociallogin/custom_oidc/authelia"];
                scopes = [
                  "openid"
                  "profile"
                  "email"
                  "groups"
                  "nextcloud_userinfo"
                ];
                response_types = "code";
                grant_types = "authorization_code";
                access_token_signed_response_alg = "none";
                userinfo_signed_response_alg = "none";
                token_endpoint_auth_method = "client_secret_basic";
              }
              {
                client_id = "open-webui";
                client_name: "open-webui";
                client_secret = "$pbkdf2-sha512$310000$c8p78n7pUMln0jzvd4aK4Q$JNRBzwAo0ek5qKn50cFzzvE9RXV88h1wJn5KGiHrD0YKtZaR/nCb2CJPOsKaPK0hjf.9yHxzQGZziziccp6Yng"; # 'insecure_secret'
                public = false;
                authorization_policy = "two_factor";
                require_pkce = true;
                pkce_challenge_method = "S256";
                redirect_uris = [ "https://ai.example.com/oauth/oidc/callback"];
                scopes = [
                  "openid"
                  "profile"
                  "groups"
                  "email"
                ];
                response_types = "code";
                grant_types = "authorization_code";
                access_token_signed_response_alg = "none";
                userinfo_signed_response_alg = "none";
                token_endpoint_auth_method = "client_secret_basic";
            ];
          };
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
