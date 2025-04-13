{
  pkgs,
  lib,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.nameservers = lib.mkForce ["127.0.0.1"];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      enable = true;
      package = pkgs.blocky;
      settings = {
        connectIPVersion = "v4";
        fqdnOnly.enable = true;
        filtering.queryTypes = ["AAAA"];
        ports.dns = "127.0.0.1:53";
        log.level = "info"; # debug
        minTlsServeVersion = "1.3";
        specialUseDomains = {
          enable = true;
          rfc6762-appendixG = true;
        };
        upstreams = {
          init.strategy = "fast"; # blocking, failOnError, fast
          timeout = "4s";
          strategy = "strict"; # strict, random, parallel_best (best two)
          groups = {
            default = [
              "tcp+udp:127.0.0.1:5353"
              "tcp+udp:192.168.0.1:53"
              "tcp+udp:192.168.1.1:53"
              "tcp+udp:192.168.8.1:53"
              "tcp+udp:9.9.9.9"
            ];
          };
        };
        bootstrapDns = [
          "tcp+udp:127.0.0.1:5353"
          "tcp+udp:192.168.0.1:53"
          "tcp+udp:192.168.1.1:53"
          "tcp+udp:192.168.8.1:53"
          "tcp+udp:9.9.9.9"
        ];
        caching = {
          cacheTimeNegative = "30m";
          minTime = "2h";
          maxTime = "24h";
          maxItemsCount = 0; # unlimited
          prefetching = true;
          prefetchExpires = "72h";
          prefetchThreshold = 1;
          prefetchMaxItemsCount = 0; # unlimited
        };
      };
    };
  };
}
