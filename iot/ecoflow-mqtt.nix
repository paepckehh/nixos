# => default web interface prometheus         http://localhost:9090
# => default web interface grafana            http://localhost:3000  (initial user/password = admin/admin)
# => import grafana dashboard at your choice: https://grafana.com/grafana/dashboards/17812-ecoflow
{config, ...}: {
  environment.etc."ecoflow-email".text = ''ecoflow@example.net'';
  environment.etc."ecoflow-password".text = ''my-supersecret-ecoflow-password'';
  environment.etc."ecoflow-devices".text = ''R330000,R340000,NC420000,...'';
  services = {
    prometheus = {
      enable = true;
      exporters.ecoflow = {
        enable = true;
        exporterType = "mqtt";
        # config example with agenix secrets:
        # ecoflowEmailFile = config.age.secrets.ecoflow-email.path;
        # ecoflowPasswordFile = config.age.secrets.ecoflow-password.path;
        # ecoflowDevicesFile = config.age.secrets.ecoflow-devices.path;
      };
      scrapeConfigs = [
        {
          job_name = "ecoflow";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString config.services.prometheus.exporters.ecoflow.port}"];
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
