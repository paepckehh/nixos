{
  lib,
  config,
  ...
}: {
  # => default web interface prometheus  http://localhost:9090
  # => default web interface grafana     http://localhost:3000  (initial user/password = admin/admin)
  # => import grafana dashboard https://grafana.com/grafana/dashboards/19186-chrony
  services = {
    timesyncd.enable = false;
    chrony.enable = true;
    prometheus = {
      enable = true;
      exporters.chrony = {
        enable = true;
      };
      scrapeConfigs = [
        {
          job_name = "chrony";
          static_configs = [
            {
              targets = ["127.0.0.1:9123"];
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
}
