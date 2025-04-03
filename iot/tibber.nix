{
  config,
  lib,
  ...
}: {
  # => import grafana dashboard at your choice:  https://github.com/terjesannum/tibber-exporter/tree/master/grafana
  environment.etc."tibber.token".text = lib.mkForce ''5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE'';
  services = {
    prometheus = {
      enable = true;
      exporters.tibber = {
        enable = true;
        apiTokenPath = /etc/tibber.token;
        # example generic public developer tibber token
        # do not share private token via github, use agenix or soaps
        # replace with your own tibber bearer api token, see https://developer.tibber.com
      };
      scrapeConfigs = [
        {
          job_name = "tibber";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString config.services.prometheus.exporters.tibber.port}"];
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
