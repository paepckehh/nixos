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
          enable = true;
          enableConfigCheck = true;
          listenAddress = "0.0.0.0";
          port = 9115;
          configFile = /etc/blackbox.yaml;
        };
      };
    };
    grafana = {
      enable = true;
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
    elasticsearch = {
      enable = false;
    };
    influxdb2 = {
      enable = false;
    };
  };
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    etc."blackbox.yml".text = lib.mkForce ''
      scrape_configs:
       - job_name: blackbox_all
          metrics_path: /probe
            params:
            module: [ http_2xx ]  # Look for a HTTP 200 response.
          dns_sd_configs:
            - names:
              - microsoft.com
              - pvz.digital
              - remote.pvz.digital
            type: A
            port: 443
          relabel_configs:
            - source_labels: [__address__]
              target_label: __param_target
              replacement: https://$1/  # Make probe URL be like https://1.2.3.4:443/
            - source_labels: [__param_target]
              target_label: instance
            - target_label: __address__
              replacement: 127.0.0.1:9115  # The blackbox exporter's real hostname:port.
            - source_labels: [__meta_dns_name]
              target_label: __param_hostname  # Make domain name become 'Host' header for probe requests
            - source_labels: [__meta_dns_name]
              target_label: vhost  # and store it in 'vhost' label
    '';
  };
}
