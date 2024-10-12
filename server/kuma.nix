{
  config,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    uptime-kuma = {
      enable = true;
      appriseSupport = false;
      settings = {
        UPTIME_KUMA_HOST = "0.0.0.0";
        UPTIME_KUMA_PORT = "4000";
      };
    };
  };
}
