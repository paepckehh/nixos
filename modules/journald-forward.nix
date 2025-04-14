{...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald = {
      storage = "volatile";
      upload = {
        enable = true;
        URL = "http://192.168.8.100";
      };
    };
  };
}
