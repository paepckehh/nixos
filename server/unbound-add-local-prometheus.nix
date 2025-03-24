{config, ...}: {
  # prometheus default web interface http://localhost:9090
  # grafana default web interface http://localhost:3000
  # grafana unbound dashboards https://github.com/ar51an/unbound-dashboard
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    unbound = {
      enable = true;
      localControlSocketPath = "/run/unbound/unbound.ctl";
      settings = {
        server = {
          extended-statistics = true;
        };
      };
    };
    prometheus = {
      enable = true;
      exporters.unbound = {
        enable = true;
        port = 9167;
        listenAddress = "127.0.0.1";
      };
      scrapeConfigs = [
        {
          job_name = "unbound";
          static_configs = [
            {
              targets = ["${config.services.prometheus.exporters.unbound.listenAddress}:${toString config.services.prometheus.exporters.unbound.port}"];
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
            access = "proxy";
            isDefault = true;
            url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          }
        ];
      };
    };
  };
}
