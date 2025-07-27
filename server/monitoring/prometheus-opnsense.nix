{config, ...}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        prometheus = {
          enable = true;
          hostname = "prometheus";
          ip = "192.168.80.210";
          ports.tcp = 443;
          db.retenetion = "365d";
          alertmanager.ports.tcp = 8443;
          exporters = {
            node = {
              ports.tcp = 9100;
              enabledCollectors = ["logind" "systemd"];
              disabledCollectors = [];
            };
            smartctl = {
              ports.tcp = 9101;
              devices = ["/dev/sda"]; # /dev/nvme
            };
          };
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
    extraHosts = "${infra.lan.services.prometheus.ip} ${infra.lan.services.prometheus.hostname} ${infra.lan.services.prometheus.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.prometheus.ports.tcp infra.lan.services.prometheus.alertmanager.ports.tcp];
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # environment.etc."asecret".text = ''ZDI1NTE5AAAAIArbsQC2gdtQ9qCC54Khfe'';

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = infra.lan.services.prometheus.enable;
      port = infra.lan.services.prometheus.ports.tcp;
      retentionTime = infra.lan.services.prometheus.db.retenetion;
      alertmanager.port = infra.lan.services.prometheus-alertmanager.ports.tcp;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "localhost:${toString config.services.prometheus.exporters.node.port}" # self
              ];
            }
          ];
        }
        {
          job_name = "smartctl";
          static_configs = [
            {
              targets = [
                "localhost:${toString config.services.prometheus.exporters.smartctl.port}" # self
              ];
            }
          ];
        }
      ];
      exporters = {
        node = {
          enable = infra.lan.services.prometheus.enable;
          port = infra.lan.services.prometheus.exporters.node.ports.tcp;
          enabledCollectors = infra.lan.services.prometheus.exporters.node.enabledCollectors;
          disabledCollectors = infra.lan.services.prometheus.exporters.node.disabledCollectors;
        };
        smartctl = {
          enable = infra.lan.services.prometheus.enable;
          port = infra.lan.services.prometheus.exporters.smartctl.ports.tcp;
          devices = infra.lan.services.prometheus.exporters.smartctl.devices;
        };
        opnsense = {
          enable = true;
          # apiKeyFile = /etc/secret;
          # apiSecretFile = /etc/secret;
        };
      };
    };
  };
}
