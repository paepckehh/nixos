{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      alertmanager.port = 9093;
      port = 9090;
      retentionTime = "128d";
      settings.WebService.AllowUnencrypted = false;
    };
  };
}
