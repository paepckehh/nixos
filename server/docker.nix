{
  config,
  pkgs,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./cockpit.nix
  ];
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    memcached = {
      enable = true;
      listen = "127.0.0.1";
      port = 11211;
      maxMemory = 16; # max. 16G
    };
  };
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        whoogle = {
          image = "benbusby/whoogle-search:latest";
          ports = ["0.0.0.0:8080:8080"];
          environment = {
            EXPOSE_PORT = "8080";
            WHOOGLE_MINIMAL = "1";
            WHOOGLE_RESULTS_PER_PAGE = "50";
            WHOOGLE_CONFIG_LANGUAGE = "en";
            WHOOGLE_CONFIG_SEARCH_LANGUAGE = "en";
            WHOOGLE_CONFIG_SAFE = "1";
            WHOOGLE_CONFIG_URL = "http://localhost:8080";
          };
        };
        speed = {
          image = "openspeedtest/latest:latest";
          ports = ["0.0.0.0:8181:8080"];
          environment = {
            HTTP_PORT = "8080";
            HTTPS_PORT = "8443";
            CHANGE_CONTAINER_PORTS = "1";
            # SET_SERVER_NAME = "speed.pvz.lan";
          };
        };
        yopass = {
          image = "jhaals/yopass:latest";
          ports = ["0.0.0.0:8282:1337"];
          cmd = ["--database=memcached" "--memcached=localhost:11211" "--port=1337" "--max-length=100000" "--metrics-port=9144"];
        };
        #grist = {
        #  image = "gristlabs/grist:latest";
        #  ports = ["0.0.0.0:8383:80"];
        #};
        # nocdb = {
        #  image = "nocdb/nocdb";
        #  ports = ["0.0.0.0:8484:80"];
        # };
        #spot = {
        #  image = "yooooomi/your_spotify_server";
        #  ports = ["0.0.0.0:8585:8080"];
        #};
      };
    };
  };
}