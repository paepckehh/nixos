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
  # => import grafana dashboard https://grafana.com/grafana/dashboards/19186-chrony/ => https://grafana.com/api/dashboards/19186/revisions/2/download
  ################
  #-=# CONFIG #=-#
  ################
  chrony.prometheus = {
    enabled = true;
    local = true;
    cmd = {
      host = "127.0.0.1";
      port = 323;
    };
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
      chrony = {
        enable = true;
        extraConfig = ''
          bindcmdaddress ${chrony.prometheus.cmd.host}
          cmdallow ${chrony.prometheus.cmd.host}/32
          cmdport ${toString chrony.prometheus.cmd.port}
          minsources 3'';
      };
      prometheus = {
        enable = chrony.prometheus.local;
        exporters.chrony = {
          enable = true;
          extraFlags = [
            "--chrony.address=${chrony.prometheus.cmd.host}:${toString chrony.prometheus.cmd.port}"
          ];
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
      etc."grafana-dashboards/chrony-grafana.json" = {
        source = "/etc/nixos/server/ntp/resources/chrony-grafana.json";
        group = "grafana";
        user = "grafana";
      };
    };
  }
