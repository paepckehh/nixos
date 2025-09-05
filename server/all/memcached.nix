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
      maxConnections = 32;
      maxMemory = 128; # mb
    };
  };
}
