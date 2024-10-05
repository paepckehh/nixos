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
      settings.WebService.AllowUnencrypted = true;
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
  prometheus.exporters.node = {
    enable = true;
    port = 9000;
    enabledCollectors = [ "systemd" "wireguard"] ;
    extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi" ];
  };
}
