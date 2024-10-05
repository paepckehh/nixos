{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      alertmanager.port = 9093;
      port = 9090;
      retentionTime = "365d";
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "127.0.0.1:9100"
                "192.168.122.2:9100"
                "192.168.122.3:9100"
              ];
            }
          ];
        }
      ];
      exporters.node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "logind"
          "systemd"
        ];
        disabledCollectors = [];
        openFirewall = true;
      };
    };
  };
}
