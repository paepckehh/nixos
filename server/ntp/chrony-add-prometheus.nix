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
  chrony.prometheus = {
    enabled = true;
    local = true;
    metrics = {
      host = "localhost";
      port = "9123";
    };
  };
in
  lib.mkIf chrony.prometheus.enabled {
    ##################
    #-=# SERVICES #=-#
    ##################
    services = {
      chrony.enable = true;
      prometheus = {
        enable = chrony.prometheus.local;
        scrapeConfigs = [
          {
            job_name = "blocky";
            static_configs = [
              {
                targets = ["${chrony.prometheus.metrics.host}:${chrony.promethes.metrics.port}"];
              }
            ];
          }
        ];
      };
      grafana = {
        enable = chrony.prometheus.local;
        provision = {
          # enable = chrony.prometheus.local;
          # dashboards.settings.providers = [
          #   {
          #     name = "pre-configured-local-dashboards";
          #    options.path = "/etc/grafana-dashboards";
          #   }
          # ];
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
    # environment = {
    #  etc."grafana-dashboards/chrony-grafana.json" = {
    #    source = "/etc/nixos/server/dns/resources/blocky-grafana.json";
    #    group = "grafana";
    #    user = "grafana";
    #  };
    # };
  }
