{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    open-webui = {
      enable = true;
      environment = ''        {
               ANONYMIZED_TELEMETRY = "False";
               DO_NOT_TRACK = "True";
               SCARF_NO_ANALYTICS = "True";
             } '';
      host = "127.0.0.1";
      port = 8080;
      openFirewall = false;
    };
  };
}
