{
  pkgs,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        opencloud = {
          ip = "192.168.80.206";
          hostname = "cloud";
          ports.tcp = 443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.opencloud.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.opencloud.ip} ${infra.lan.services.opencloud.hostname} ${infra.lan.services.opencloud.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.opencloud.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    opencloud = {
      enable = true;
      address = "${infra.lan.services.opencloud.ip}";
      port = infra.lan.services.opencloud.ports.tcp;
      environment = {
        INSECURE = "true";
        LOG_DRIVER = "local";
        LOG_PRETTY = "true";
        # TRAEFIK_DASHBOARD = "false";
        # TRAEFIK_DOMAIN = "traefik.opencloud.lan";
        # TRAEFIK_BASIC_AUTH_USERS = "admin:$2y$05$KDHu3xq92SPaO3G8Ybkc7edd51pPLJcG1nWk3lmlrIdANQ/B6r5pq";
        # TRAEFIK_ACME_MAIL = "acme@pki.lan";
        # TRAEFIK_ACME_CASERVER = "https://pki.lan/acme/acme/directory";
        OC_INSECURE = "true";
        OC_LOG_LEVEL = "info";
        OC_DOMAIN = "${infra.lan.services.opencloud.hostname}";
      };
      settings = {
        proxy = {
          auto_provision_accounts = true;
          oidc = {
            rewrite_well_known = true;
          };
          role_assignment = {
            driver = "oidc";
            oidc_role_mapper = {
              role_claim = "opencloud_roles";
            };
          };
        };
        web = {
          web = {
            config = {
              oidc = {
                scope = "openid profile email opencloud_roles";
              };
            };
          };
        };
      };
    };
  };
}
