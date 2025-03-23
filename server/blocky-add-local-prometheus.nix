{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      enable = true;
      settings = {
        ports.http = "127.0.0.1:4000"; # /metrics -> prometheus
        prometheus = {
          enable = true;
          path = "/metrics";
        };
      };
    };
    prometheus = {
      # defaults to http://localhost:9090
      enable = true;
      scrapeConfigs = [
        {
          job_name = "blocky";
          static_configs = [
            {
              targets = ["127.0.0.1:4000"];
            }
          ];
        }
      ];
    };
    grafana = {
      # defaults to http://localhost:3000
      enable = true;
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            isDefault = true;
            url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          }
        ];
      };
    };
  };
}
