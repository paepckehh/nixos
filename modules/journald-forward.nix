{...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald = {
      storage = "volatile";
      upload = {
        enable = true;
        settings.Upload.URL = "http://192.168.8.100";
      };
    };
  };
}
