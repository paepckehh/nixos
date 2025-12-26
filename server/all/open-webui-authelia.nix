# ai openwebui open-webui openweb-ui
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
  networking.extraHosts = "${infra.ai.ip} ${infra.ai.hostname} ${infra.ai.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.open-webui = {
    after = ["socket.target"];
    wants = ["socket.target"];
    wantedBy = ["multi-user.target"];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    authelia.instances."${infra.sso.site}".settings.identity_providers.oidc.clients = [
      {
        client_id = infra.ai.app;
        client_name = infra.ai.app;
        client_secret = "$pbkdf2-sha512$310000$c8p78n7pUMln0jzvd4aK4Q$JNRBzwAo0ek5qKn50cFzzvE9RXV88h1wJn5KGiHrD0YKtZaR/nCb2CJPOsKaPK0hjf.9yHxzQGZziziccp6Yng"; # 'insecure_secret'
        public = false;
        authorization_policy = infra.sso.oidc.policy;
        require_pkce = true;
        scopes = infra.sso.oidc.scopes;
        pkce_challenge_method = infra.sso.oidc.method;
        redirect_uris = ["${infra.ai.url}/oauth/oidc/callback"];
        response_types = infra.sso.oidc.response.code;
        grant_types = "authorization_code";
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = infra.sso.oidc.auth.basic;
        consent_mode = infra.sso.oidc.consent;
      }
    ];
    open-webui = {
      enable = true;
      host = infra.localhost.ip;
      port = infra.ai.localbind.port.http;
      environment = {
        # WEBUI_AUTH_COOKIE_SAME_SITE = "lax";
        # WEBUI_SESSION_COOKIE_SAME_SITE = "lax";
        # DEFAULT_USER_ROLE = "user";
        # ENABLE_OAUTH_ROLE_MANAGEMENT = infra.true;
        SSL_CERT_FILE = infra.pki.certs.rootCA.path;
        WEBUI_URL = infra.ai.url;
        WEBUI_SECRET_KEY = "gvtwmbktrnkbnkrnbkrsghtrHRbrBRBrgf";
        OLLAMA_BASE_URL = infra.ai.worker.one;
        MODELS_CACHE_TTL = "600";
        CHAT_RESPONSE_STREAM_DELTA_CHUNK_SIZE = "6";
        DEFAULT_LOCALE = "de";
        ENABLE_API_KEY = infra.false;
        ENABLE_PERSISTENT_CONFIG = infra.false;
        ENABLE_OPENAI_API = infra.false;
        ENABLE_OLLAMA_API = infra.true;
        ENABLE_VERSION_UPDATE_CHECK = infra.false;
        ENABLE_WEB_SEARCH = infra.true;
        WEB_SEARCH_ENGINE = infra.search.app; # fixed token: searxng
        SEARXNG_QUERY_URL = infra.search.query.url;
        ENABLE_LOGIN_FORM = infra.false;
        ENABLE_OAUTH_SIGNUP = infra.true;
        OPENID_PROVIDER_URL = infra.sso.oidc.discoveryUri;
        OPENID_REDIRECT_URI = "${infra.ai.url}/oauth/oidc/callback";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = infra.true;
        OAUTH_CLIENT_ID = infra.ai.app;
        OAUTH_CLIENT_SECRET = "insecure_secret";
        OAUTH_SCOPES = infra.sso.oidc.scope;
        OAUTH_CODE_CHALLENGE_METHOD = infra.sso.oidc.method;
        OAUTH_PROVIDER_NAME = infra.sso.app;
        OAUTH_ALLOWED_ROLES = "users,admin";
        OAUTH_ADMIN_ROLES = "admin";
        OAUTH_ROLES_CLAIM = "groups";
        OAUTH_UPDATE_PICTURE_ON_LOGIN = infra.true;
        ENABLE_OAUTH_PERSISTENT_CONFIG = infra.false;
      };
    };
    caddy.virtualHosts."${infra.ai.fqdn}" = {
      listenAddresses = [infra.ai.ip];
      extraConfig = ''import intraproxy ${toString infra.ai.localbind.port.http}'';
    };
  };
}
