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
      backend = "podman";
      containers = {
        yo = {
          # image = "jhaals/yopass:latest";
          image = "ghcr.io/paepckehh/yopass-ng:latest";
          cmd = ["--address=0.0.0.0" "--port=8282" "--metrics-port=9144" "--database=memcached" "--memcached=localhost:11211"];
          extraOptions = ["--network=host"];
        };
      };
    };
  };
}
