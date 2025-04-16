# => default web interface prometheus         http://localhost:9090
# => default web interface grafana            http://localhost:3000  (initial user/password = admin/admin)
# => import grafana dashboard at your choice: https://grafana.com/grafana/dashboards/17812-ecoflow
{config, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../modules/agenix.nix
  ];

  #############
  #-=# AGE #=-#
  #############
  age = {
    ecoflow-email = {
      file = ./resources/ecoflow-email.age;
      owner = "prometheus";
      group = "prometheus";
    };
    ecoflow-password = {
      file = ./resources/ecoflow-password.age;
      owner = "prometheus";
      group = "prometheus";
    };
    ecoflow-devices = {
      file = ./resources/ecoflow-devices.age;
      owner = "prometheus";
      group = "prometheus";
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc = {
    "ecoflow-email".text = ''ecoflow@example.net'';
    "ecoflow-password".text = ''my-supersecret-ecoflow-password'';
    "ecoflow-devices".text = ''R330000,R340000,NC420000,...'';
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    resolved = {
      # mqtt needs multicastDNS support
      enable = true;
      llmnr = "true"; # string: true, false, resolve
      extraConfig = "MulticastDNS=true\nCache=true\nCacheFromLocalhost=true\n";
    };
    prometheus = {
      enable = true;
      exporters.ecoflow = {
        enable = true;
        exporterType = "mqtt";
        # config example with agenix secrets:
        ecoflowEmailFile = config.age.secrets.ecoflow-email.path;
        ecoflowPasswordFile = config.age.secrets.ecoflow-password.path;
        ecoflowDevicesFile = config.age.secrets.ecoflow-devices.path;
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
