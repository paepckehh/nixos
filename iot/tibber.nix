# => default web interface prometheus          http://localhost:9090
# => default web interface grafana             http://localhost:3000  (initial user/password = admin/admin)
# => import grafana dashboard at your choice:  https://github.com/terjesannum/tibber-exporter/tree/master/grafana
{
  config,
  lib,
  ...
}: {
  environment.etc."tibber.token".text = lib.mkForce ''5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE'';
  services = {
    prometheus = {
      enable = true;
      exporters.tibber = {
        enable = true;
        # apiTokenPath = config.age.secrets.tibber.path; # needs agenix secrets
        apiTokenPath = /etc/tibber.token; # example generic public developer tibber token
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
