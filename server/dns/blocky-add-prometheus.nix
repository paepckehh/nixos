{lib, ...}: let
  ################
  #-=# CONFIG #=-#
  ################
  # default web interface prometheus  http://localhost:9090
  # default web interface grafana     http://localhost:3000  (initial user/password = admin/admin)
  blocky.prometheus = {
    enabled = true;
    metrics = {
      host = "localhost";
      port = "4000";
    };
  };
in
  (lib.mkIf blocky.prometheus.enabled {
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
    };
  })
  (lib.mkIf blocky.prometheus.metrics.host
    == "localhost" {
      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        prometheus = {
          enable = true;
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
          enable = true;
          provision = {
            enable = true;
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
    })
