{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    cockpit = {
      enable = false;
      port = 9090;
      settings.WebService.AllowUnencrypted = false;
    };
  };
}
