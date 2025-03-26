{config, ...}: {
  # prometheus default web interface http://localhost:9090
  # grafana default web interface http://localhost:3000
  # grafana dashboards https://github.com/0xERR0R/blocky/tree/main/docs

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
}
