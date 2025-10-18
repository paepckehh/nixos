{
  config,
  lib,
  pkgs,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        prometheus = {
          ip = "192.168.80.210";
          hostname = "prometeus";
          ports.tcp.app = 443;
          ports.tcp.alertmanager = 8443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.prometheus.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.prometheus.ip} ${infra.lan.services.prometheus.hostname} ${infra.lan.services.pki.prometheus}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.prometheus.ports.tcp.app infra.lan.services.prometheus.ports.tcp.alertmanager];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      port = infra.lan.services.prometheus.ports.tcp.app;
      retentionTime = "180d";
      alertmanager.port = infra.lan.services.prometheus.ports.tcp.appmanager;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" # self
              ];
            }
          ];
        }
        {
          job_name = "smartctl";
          static_configs = [
            {
              targets = [
                "localhost:9633"
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
        smartctl = {
          enable = true;
          devices = ["/dev/sda"];
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
  };
}
