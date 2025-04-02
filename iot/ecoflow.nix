{config, ...}: {
  # => default web interface prometheus  http://localhost:9090
  # => default web interface grafana     http://localhost:3000  (initial user/password = admin/admin)
  # => import grafana dashboard at your choice:
  services = {
    prometheus = {
      enable = true;
      exporters.ecoflow = {
        enable = true;
        accessKey = "ecoflow@example.net";
        secretKey = "supersecret";
      };
      scrapeConfigs = [
        {
          job_name = "ecoflow";
          static_configs = [
            {
              targets = ["127.0.0.1:2112"];
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
