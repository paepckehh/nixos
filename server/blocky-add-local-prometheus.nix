{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      enable = true;
      settings = {
        prometheus = {
          enable = true;
          path = "/metrics";
        };
      };
    };
    prometheus = {
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
      enable = true;
      provision.enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
        }
      ];
    };
  };
}
