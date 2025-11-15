{config, ...}:
{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    open-webui = {
      enable = true;
      host = "127.0.0.1";
      port = 6161;
      environment = {
        ENABLE_PERSISTENT_CONFIG = "true";
        WEBUI_URL = "https://ai.dbt.corp";
        ENABLE_LDAP = "true";
        LDAP_SERVER_LABEL = "ldap";
        LDAP_SERVER_HOST = "ldap.dbt.corp";
        LDAP_SERVER_PORT = "389";
        LDAP_USE_TLS = "false";
        LDAP_VALIDATE_CERT = "false";
        LDAP_APP_DN = "cn=bind,ou=persons,dc=dbt,dc=corp";
        LDAP_APP_PASSWORD = "bind";
        LDAP_SEARCH_BASE = "dc=example,dc=org";
        LDAP_ATTRIBUTE_FOR_USERNAME = "uid";
        LDAP_ATTRIBUTE_FOR_MAIL = "mail";
        LDAP_SEARCH_FILTER = "(uid=%(user)s)";
        ENABLE_RAG_WEB_SEARCH = true;
        RAG_WEB_SEARCH_ENGINE = "searxng";
        RAG_WEB_SEARCH_RESULT_COUNT = 5;
        RAG_WEB_SEARCH_CONCURRENT_REQUESTS = 25;
        SEARXNG_QUERY_URL = "https://suche.dbt.corp/search?q=<query>";
      };
    };
  };
}
# webarchiv, archiv, archive, wayback, bookmark
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
    open-webui = {
      enable = true;
      host = infra.ai.localhost.ip;
      port = infra.ai.localbind.port.http;
      environment = {
        ENABLE_VERSION_UPDATE_CHECK = false;
        CHAT_RESPONSE_STREAM_DELTA_CHUNK_SIZE = "6";
        DEFAULT_LOCALE = infra.locale;
        DEFAULT_USER_ROLE = "user";
        ENABLE_API_KEY = infra.false;
        ENABLE_PERSISTENT_CONFIG = infra.false;
        ENABLE_OPENAI_API = infra.false;
        ENABLE_OLLAMA_API = infra.true;
        ENABLE_SIGNUP = infra.true;
        ENABLE_SIGNUP_PASSWORD_CONFIRMATION = infra.true;
        ENABLE_VERSION_UPDATE_CHECK = infra.false;
        ENABLE_WEB_SEARCH = infra.true;
        ENABLE_LDAP = infra.true;
        LDAP_SEARCH_BASE = infra.ldap.base;
        LDAP_SERVER_LABEL = infra.ldap.fqdn;
        LDAP_ATTRIBUTE_FOR_MAIL = "mail";
        LDAP_ATTRIBUTE_FOR_USERNAME = "uid";
        LDAP_APP_DN = infra.ldap.bind.dn;
        LDAP_APP_PASSWORD = infra.ldap.bind.pwd;
        LDAP_SERVER_HOST = infra.ldap.fqdn;
        LDAP_SERVER_PORT = "${toString infra.ldap.port}";
        LDAP_USE_TLS = infra.false;
        LDAP_VALIDATE_CERT = infra.false;
        OLLAMA_BASE_URL = infra.ai.worker.one;
        MODELS_CACHE_TTL = "600";
        SEARXNG_QUERY_URL = "https://${infra.search.fqdn}/search?q=<query>";
        WEBUI_URL = "https://${infra.ai.fqdn}";
        WEB_SEARCH_ENGINE = "searxng";
      };
    };
    caddy = {
      virtualHosts."${infra.ai.fqdn}" = {
        listenAddresses = [infra.ai.ip];
        extraConfig = ''
          reverse_proxy ${infra.ai.ip}:${toString infra.ai.localbind.ports.http}
          @not_intranet { not remote_ip ${infra.ai.access.cidr} }
          respond @not_intranet 403'';
      };
    };
  };
}
