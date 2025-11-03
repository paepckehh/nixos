{config, ...}: {
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
