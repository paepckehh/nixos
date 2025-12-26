# immich share media
# authelia/oauth app settings: https://docs.immich.app/administration/oauth/
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
  networking.extraHosts = "${infra.immich.ip} ${infra.immich.hostname} ${infra.immich.fqdn}";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    authelia.instances."${infra.sso.site}".settings.identity_providers.oidc.clients = [
      {
        client_secret = "$pbkdf2-sha512$310000$c8p78n7pUMln0jzvd4aK4Q$JNRBzwAo0ek5qKn50cFzzvE9RXV88h1wJn5KGiHrD0YKtZaR/nCb2CJPOsKaPK0hjf.9yHxzQGZziziccp6Yng"; # 'insecure_secret'
        client_id = infra.immich.app;
        client_name = infra.immich.app;
        public = false;
        require_pkce = false;
        # pkce_challenge_method = infra.sso.oidc.method;
        authorization_policy = infra.sso.oidc.policy;
        scopes = infra.sso.oidc.scopes;
        response_types = infra.sso.oidc.response.code;
        grant_types = infra.sso.oidc.grant;
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = infra.sso.oidc.auth.post;
        consent_mode = infra.sso.oidc.consent;
        redirect_uris = [
          "${infra.immich.url}/auth/login"
          "${infra.immich.url}/user-settings"
          "app.immich:///oauth-callback"
        ];
      }
    ];
    immich = {
      enable = true;
      host = infra.localhost.ip;
      port = infra.immich.localbind.port.http;
      settings = {
        server.externalDomain = infra.immich.url;
        passwordLogin.enabled = true;
        oauth = {
          enabled = true;
          autoLaunch = true;
          autoRegister = true;
          buttonText = "Anmeldung mit Authelia";
          clientId = infra.immich.app;
          clientSecret = "insecure_secret";
          issuerUrl = infra.sso.url;
          profileSigningAlgorithm = "none";
          roleClaim = "immich_role";
          scope = infra.sso.oidc.scope;
          signingAlgorithm = "RS256";
          storageLabelClaim = "preferred_username";
          storageQuotaClaim = "immich_quota";
          timeout = 30000;
          tokenEndpointAuthMethod = infra.sso.oidc.auth.post;
        };
      };
    };
    caddy.virtualHosts."${infra.immich.fqdn}" = {
      listenAddresses = [infra.immich.ip];
      extraConfig = ''import intraproxy ${toString infra.immich.localbind.port.http}'';
    };
  };
}
