{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/home.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.search.ip} ${infra.search.hostname} ${infra.search.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapps;
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
    searx = {
      enable = true;
      redisCreateLocally = false; # bot protection
      configureUwsgi = false;
      configureNginx = false;
      settings = {
        retries = 1;
        max_connections = 250;
        max_keepalive_connections = 50;
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
    caddy = {
      enable = true;
      virtualHosts = {
        "${infra.search.fqdn}".extraConfig = ''
          bind ${infra.search.ip}
          reverse_proxy ${infra.localhost.ip}:${toString infra.search.localbind.port.http}
          tls ${infra.pki.acme.contact} {
                ca_root ${infra.pki.certs.rootCA.path}
                ca ${infra.pki.acme.url}
          }
          @not_intranet {
            not remote_ip ${infra.search.access.cidr}
          }
          respond @not_intranet 403
          log {
            output file ${config.services.caddy.logDir}/access/${infra.search.name}.log
          }
        '';
      };
    };
  };
}
