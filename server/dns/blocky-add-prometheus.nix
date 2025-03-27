{
  lib,
  config,
  ...
}: let
  ##############
  #-=# INFO #=-#
  ##############
  # set blocky.prometheus.local = true to host prometheus and grafana locally
  # => default web interface prometheus  http://localhost:9090
  # => default web interface grafana     http://localhost:3000  (initial user/password = admin/admin)
  ################
  #-=# CONFIG #=-#
  ################
  blocky.prometheus = {
    enabled = true;
    local = true;
    metrics = {
      host = "localhost";
      port = "4000";
    };
  };
in
  lib.mkIf blocky.prometheus.enabled {
    ##################
    #-=# SERVICES #=-#
    ##################
    services = {
      blocky = {
        enable = true;
        settings = {
          ports.http = "${blocky.prometheus.metrics.host}:${blocky.prometheus.metrics.port}"; # /metrics -> prometheus
          prometheus = {
            enable = true;
            path = "/metrics";
          };
        };
      };
      prometheus = {
        enable = blocky.prometheus.local;
        scrapeConfigs = [
          {
            job_name = "blocky";
            static_configs = [
              {
                targets = ["${config.services.blocky.settings.ports.http}"];
              }
            ];
          }
        ];
      };
      grafana = {
        enable = blocky.prometheus.local;
        provision = {
          enable = true;
          dashboards.settings.providers = [
            {
              name = "pre-configured-local-dashboards";
              options.path = "/etc/grafana-dashboards";
            }
          ];
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
            }
          ];
        };
      };
    };
    #####################
    #-=# ENVIRONMENT #=-#
    #####################
    environment = {
      etc."grafana-dashboards/blocky-grafana.json" = {
        source = "/etc/nixos/server/dns/resources/blocky-grafana.json";
        group = "grafana";
        user = "grafana";
      };
    };
  }
