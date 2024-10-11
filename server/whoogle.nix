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
      ports = ["0.0.0.0:8080:80"];
      environment = {
        EXPOSE_PORT = "80";
        WHOOGLE_MINIMAL = " 1 ";
        WHOOGLE_RESULTS_PER_PAGE = " 50 ";
        WHOOGLE_CONFIG_LANGUAGE = " en ";
        WHOOGLE_CONFIG_SEARCH_LANGUAGE = " en ";
        WHOOGLE_CONFIG_SAFE = " 1 ";
        WHOOGLE_CONFIG_URL = "http://localhost:8080";
      };
    };
    baserow = {
      image = "baserow/baserow";
      ports = ["0.0.0.0:8181:80"];
      environment = {
        BASEROW_PUBLIC_URL = "http://localhost:8181";
      };
      volumes = [
        "baserow_data:/var/baserow/data"
      ];
    };
    grist = {
      image = "gristlabs/grist";
      ports = ["0.0.0.0:8282:80"];
    };
    speedtest = {
      image = "openspeedtest/latest";
      ports = ["0.0.0.0:8383:80"];
    };
    # nocdb = {
    #  image = "nocdb/nocdb";
    #  ports = ["0.0.0.0:8484:80"];
    # };
    #spot = {
    #  image = "yooooomi/your_spotify_server";
    #  ports = ["0.0.0.0:8585:8080"];
    #};
  };
}
