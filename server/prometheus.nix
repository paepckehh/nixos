{
  config,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      port = 9191;
      retentionTime = "365d";
      alertmanager = {
        port = 9292;
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" # self
                "192.168.122.2:9100" # example opnsense node IP
                "192.168.122.3:9100" # example opnsense node IP
              ];
            }
          ];
        }
        {
          job_name = "haproxy";
          static_configs = [
            {
              targets = [
                "192.168.122.2:8404" # example opnsense node IP
                "192.168.122.3:8404" # example opnsense node IP
              ];
            }
          ];
        }
      ];
      exporters = {
        node = {
          enable = true;
          port = 9100;
          enabledCollectors = [
            "logind"
            "systemd"
          ];
          disabledCollectors = [];
          openFirewall = true;
        };
        blackbox = {
          enable = false;
          enableConfigCheck = false;
          configFile = /etc/nixos/server/resources/blackbox.yml;
          listenAddress = "0.0.0.0";
          port = 9115;
        };
      };
    };
    grafana = {
      enable = true;
      provision.enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 9090;
          domain = "localhost";
        };
      };
    };
    graylog = {
      enable = false;
      passwordSecret = "start";
      rootPasswordSha2 = "cced28c6dc3f99c2396a5eaad732bf6b28142335892b1cd0e6af6cdb53f5ccfa";
      elasticsearchHosts = ["http://127.0.0.1:9200"];
    };
    karma = {
      enable = false;
      openFirewall = false;
      settings.listen = {
        port = 9494;
        address = "0.0.0.0";
      };
    };
    elasticsearch = {
      enable = false;
    };
    influxdb2 = {
      enable = false;
    };
  };
}
