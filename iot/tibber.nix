{config, ...}: {
  # => default web interface prometheus  http://localhost:9090
  # => default web interface grafana     http://localhost:3000  (initial user/password = admin/admin)
  # => import grafana dashboard at your choice:  https://github.com/terjesannum/tibber-exporter/tree/master/grafana
  services = {
    prometheus = {
      enable = true;
      exporters.tibber = {
        enable = true;
        apiToken = "5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE";
        # tibber bearer token
        # replace this generic developer example token with your personal one
        # keep it safe, do not share (via github) with anyone (agenix, sops, ...)
      };
      scrapeConfigs = [
        {
          job_name = "tibber";
          static_configs = [
            {
              targets = ["127.0.0.1:8080"];
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
