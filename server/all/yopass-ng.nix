{config, ...}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [8443]; # open port 8443 on all interfaces
    };
  };
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    memcached = {
      enable = true;
      maxConnections = 16; # max conncurrent r/w sessions
      maxMemory = 512; # max storage alloc in mb (megabytes)
    };
  };
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        yo = {
          # image = "jhaals/yopass:latest";
          image = "ghcr.io/paepckehh/yopass-ng"; # bind to all interfaces, port 8443
          cmd = ["--address=0.0.0.0" "--port=8282" "--metrics-port=9144" "--database=memcached" "--memcached=localhost:11211"];
          extraOptions = ["--network=host"];
        };
      };
    };
  };
}
