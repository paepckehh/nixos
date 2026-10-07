{
  config,
  pkgs,
  lib,
  infra,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald = {
      storage = lib.mkForce "volatile";
      upload = {
        enable = lib.mkForce true;
        settings.Upload.URL = lib.mkForce infra.syslog.url;
      };
    };
  };
}
