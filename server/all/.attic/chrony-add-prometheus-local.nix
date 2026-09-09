{
  lib,
  config,
  ...
}: let
  ##############
  #-=# INFO #=-#
  ##############
  # set chrony.prometheus.local = true to host prometheus and grafana locally
  # => default web interface prometheus  http://localhost:9090
  # => default web interface grafana     http://localhost:3000  (initial user/password = admin/admin)
  # => import grafana dashboard https://grafana.com/grafana/dashboards/19186-chrony
  ################
  #-=# CONFIG #=-#
  ################
  chrony.prometheus = {
    enabled = true;
    local = true;
    metrics = {
      host = "127.0.0.1";
      port = 9123;
    };
  };
in
  lib.mkIf chrony.prometheus.enabled {
    ##################
    #-=# SERVICES #=-#
    ##################
    services = {
      timesyncd.enable = false;
      chrony.enable = true;
      prometheus = {
        enable = chrony.prometheus.local;
        exporters.chrony = {
          enable = true;
        };
        scrapeConfigs = [
          {
            job_name = "chrony";
            static_configs = [
              {
                targets = ["${chrony.prometheus.metrics.host}:${toString chrony.prometheus.metrics.port}"];
              }
            ];
          }
        ];
      };
      grafana = {
        enable = chrony.prometheus.local;
        provision = {
          enable = chrony.prometheus.local;
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
  }
