# SEARCH => SEARX, use https://${infra.dns.fqdn/search?q=%s  or https://${infra.dns.fqdn/search?q=<searchterm>
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
  networking.extraHosts = "${infra.search.ip} ${infra.search.hostname} ${infra.search.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network.networks."user".addresses = [{Address = "${infra.search.ip}/32";}];
    services = {
      searx-init = {
        after = ["sockets.target"];
        wants = ["sockets.target"];
        wantedBy = ["multi-user.target"];
      };
      searx = {
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.searx = {};
    users = {
      searx = {
        group = "searx";
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
    caddy.virtualHosts."${infra.search.fqdn}" = {
      listenAddresses = [infra.search.ip];
      extraConfig = ''import intraproxy ${toString infra.search.localbind.port.http}'';
    };
    searx = {
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
  };
}
