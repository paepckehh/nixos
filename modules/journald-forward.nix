{lib, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald = {
      storage = lib.mkForce "volatile";
      upload = {
        enable = lib.mkForce true;
        settings.Upload.URL = lib.mkForce "http://192.168.8.100";
      };
    };
  };
}
