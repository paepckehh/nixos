{config, ...}: {
  ##############
  #-=# INFO #=-#
  ##############
  #
  # perform on openwrt [ssh]
  # apk add prometheus-node-exporter-lua
  # apk add prometheus-node-exporter-lua-nat_traffic
  # apk add prometheus-node-exporter-lua-netstat
  # apk add prometheus-node-exporter-lua-openwrt
  # apk add prometheus-node-exporter-lua-wifi
  # apk add prometheus-node-exporter-lua-wifi_stations
  # edit vi /etc/config/prometheus-node-exporter-lua: listen interface and port (see below, targets)
  # service prometheus-node-exporter-lua restart
  #
  # nixos:
  # => default web interface prometheus  http://localhost:9090
  # => default web interface grafana     http://localhost:3000  (initial user/password = admin/admin)
  # add dashboard as you like from grafana.com, example: https://grafana.com/grafana/dashboards/11147-openwrt
  # need more help? https://www.cloudrocket.at/posts/monitor-openwrt-nodes-with-prometheus/
  # https://github.com/try2codesecure/grafana_dashboards
  #

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    etc."grafana-dashboards/openwrt1.json" = {
      source = "/etc/nixos/openwrt/resources/openwrt1.json";
      group = "grafana";
      user = "grafana";
    };
    etc."grafana-dashboards/openwrt2.json" = {
      source = "/etc/nixos/openwrt/resources/openwrt2.json";
      group = "grafana";
      user = "grafana";
    };

    ##################
    #-=# SERVICES #=-#
    ##################
    services = {
      prometheus = {
        enable = true;
        scrapeConfigs = [
          {
            job_name = "openwrt";
            static_configs = [
              {
                targets = ["192.168.8.1:9100"];
              }
            ];
          }
        ];
      };
      grafana = {
        enable = true;
        provision = {
          enable = true;
          dashboards.settings.providers = [
            {
              name = "pre-configured-local-dashboards";
              options.path = "/etc/grafana-dashboards";
            }
          ];
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
  };
}
