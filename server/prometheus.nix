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
      settings.WebService.AllowUnencrypted = false;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = ["127.0.0.1:9100"];
            }
          ];
        }
      ];
    };
  };
}
