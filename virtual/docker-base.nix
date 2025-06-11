{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    memcached = {
      enable = true;
      maxConnections = 128;
      maxMemory = 512; # mb
    };
  };
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "docker";
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
          ports = ["0.0.0.0:8181:3000"];
          environment = {
            SET_SERVER_NAME = "speed.pvz.lan";
          };
        };
        yo = {
          image = "jhaals/yopass:latest";
          cmd = ["--address=0.0.0.0" "--port=8282" "--metrics-port=9144" "--database=memcached" "--memcached=localhost:11211"];
          extraOptions = ["--network=host"];
        };
        status = {
          image = "adamboutcher/statping-ng:latest";
          ports = ["0.0.0.0:8383:8080"];
        };
        chef = {
          image = "ghcr.io/gchq/cyberchef:latest";
          ports = ["0.0.0.0:8484:80"];
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
    };
  };
}
