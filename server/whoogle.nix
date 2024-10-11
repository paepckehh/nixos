{
  config,
  pkgs,
  ...
}: {
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation.oci-containers.containers.whoogle = {
    image = "benbusby/whoogle-search";
    ports = ["0.0.0.0:5000:5000"];
    environment = {
      HTTPS_ONLY = " 1 ";
      WHOOGLE_MINIMAL = " 1 ";
      WHOOGLE_RESULTS_PER_PAGE = " 50 ";
      WHOOGLE_CONFIG_LANGUAGE = " en ";
      WHOOGLE_CONFIG_SEARCH_LANGUAGE = " en ";
      WHOOGLE_CONFIG_SAFE = " 1 ";
      WHOOGLE_CONFIG_URL = " http://localhost:50000 ";
    };
  };
}
