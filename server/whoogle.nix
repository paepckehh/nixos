{
  config,
  pkgs,
  ...
}: {
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation.oci-containers.containers = {
    whoogle = {
      image = "benbusby/whoogle-search";
      ports = ["0.0.0.0:8080:8080"];
      environment = {
        EXPOSE_PORT = "8080";
        WHOOGLE_MINIMAL = " 1 ";
        WHOOGLE_RESULTS_PER_PAGE = " 50 ";
        WHOOGLE_CONFIG_LANGUAGE = " en ";
        WHOOGLE_CONFIG_SEARCH_LANGUAGE = " en ";
        WHOOGLE_CONFIG_SAFE = " 1 ";
        WHOOGLE_CONFIG_URL = "http://localhost:8080";
      };
    };
    nocdb = {
      image = "nocdb/nocdb";
      ports = ["0.0.0.0:8181:8080"];
      environment = {
        EXPOSE_PORT = "8080";
      };
    };
    baserow = {
      image = "baserow/baserow";
      ports = ["0.0.0.0:8282:8080"];
      environment = {
        EXPOSE_PORT = "8080";
      };
    };
    grist = {
      image = "gristlabs/grist";
      ports = ["0.0.0.0:8383:8080"];
      environment = {
        EXPOSE_PORT = "8080";
      };
    };
    speedtest = {
      image = "openspeedtest/latest";
      ports = ["0.0.0.0:8484:8080"];
      environment = {
        EXPOSE_PORT = "8080";
      };
    };
    spot = {
      image = "yooooomi/your_spotify_server";
      ports = ["0.0.0.0:8585:8080"];
      environment = {
        EXPOSE_PORT = "8080";
      };
    };
  };
}
