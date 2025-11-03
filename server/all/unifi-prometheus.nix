{
  config,
  pkgs,
  lib,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedUDPPorts = [];
      allowedTCPPorts = [9191 9292];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      port = 9191;
      retentionTime = "180d";
      alertmanager = {
        port = 9292;
      };
      exporters = {
        node = {
          enable = true;
          port = 9100;
          enabledCollectors = [
            "logind"
            "systemd"
          ];
        };
        smartctl = {
          enable = true;
          devices = ["/dev/sda"]; # /dev/nvme0
        };
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];}];
        }
        {
          job_name = "smartctl";
          static_configs = [{targets = ["localhost:9633"];}];
        }
        {
          job_name = "unpoller";
          static_configs = [{targets = ["localhost:9130"];}];
        }
      ];
    };
  };
}
