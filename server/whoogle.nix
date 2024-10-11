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
    image = "benbusby/whoogle-search:latest";
    ports = ["0.0.0.0:8080:5000"];
    environment = {
      EXPOSE_PORT = "5000";
      WHOOGLE_MINIMAL = " 1 ";
      WHOOGLE_RESULTS_PER_PAGE = " 50 ";
      WHOOGLE_CONFIG_LANGUAGE = " en ";
      WHOOGLE_CONFIG_SEARCH_LANGUAGE = " en ";
      WHOOGLE_CONFIG_SAFE = " 1 ";
      WHOOGLE_CONFIG_URL = " http://localhost:50000 ";
    };
  };
    nocdb = {
    image = "nocdb/nocdb:latest";
    ports = ["0.0.0.0:8181:5000"];
    environment = {
      EXPOSE_PORT = "5000";
    };
  };
}
