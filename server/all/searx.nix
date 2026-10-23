{
  lib,
  infra,
  ...
}:
lib.mkMerge [
  (import ../../lib/proxy.nix {
    inherit infra;
    name = "searx";
  })
  {
    ##################
    #-=# SERVICES #=-#
    ##################
    services.searx = {
      enable = true;
      redisCreateLocally = false; # bot protection
      configureUwsgi = false;
      configureNginx = false;
      settings = {
        retries = 2;
        max_connections = 100;
        max_keepalive_connections = 40;
        search = {
          safe_search = 2;
          autocomplete = "duckduckgo";
          max_page = 0;
        };
        server = {
          base_url = infra.search.url;
          port = infra.search.localbind.port.http;
          bind_address = infra.localhost.ip;
          secret_key = "start"; # corp intranet mode
        };
        proxies = infra.proxies;
        faviconsSettings = {
          favicons = {
            cfg_schema = 1;
            cache = {
              db_url = "/var/cache/searx/faviconcache.db";
              HOLD_TIME = 5184000;
              LIMIT_TOTAL_BYTES = 2147483648;
              BLOB_MAX_BYTES = 40960;
              MAINTENANCE_MODE = "auto";
              MAINTENANCE_PERIOD = 1200;
            };
          };
        };
      };
    };
  }
]
