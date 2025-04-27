# => default web interface prometheus         http://localhost:9090
# => default web interface grafana            http://localhost:3000  (initial user/password = admin/admin)
# => import grafana dashboard at your choice: https://grafana.com/grafana/dashboards/17812-ecoflow
{config, ...}: {
  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    ecoflow-acccess-key = {
      file = ../modules/resources/ecoflow-access-key.age;
      owner = "prometheus";
      group = "prometheus";
    };
    ecoflow-secret-key = {
      file = ../modules/resources/ecoflow-secret-key.age;
      owner = "prometheus";
      group = "prometheus";
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc = {
    "ecoflow-access-key".text = ''xxxxdxxxxxxxxxxx'';
    "ecoflow-secret-key".text = ''xxxxxxxxxxxxxxxx'';
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      exporters.ecoflow = {
        enable = true;
        exporterType = "rest";
        # config example with agenix secrets:
        ecoflowAccessKeyFile = config.age.secrets.ecoflow-access-key.path;
        ecoflowSecretKeyFile = config.age.secrets.ecoflow-secret-key.path;
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
