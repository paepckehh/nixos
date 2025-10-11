{
  pkgs,
  lib,
  ...
}: {
  ##############
  #-=# INFO #=-#
  ##############
  # provides [default] systemd local resolver localhost ip:127.0.0.53 port:[53|54] [tcp|udp] and provides matching /etc/resolve.conf
  # uses local upstream blocky, privacy and malware filtering dns proxy localhost ip:127.0.0.55 port:53 [tcp|udp], query logging via syslog

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases."log.dns.resolved" = ''sudo resolvectl monitor'';

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    resolvconf.enable = lib.mkForce false;
    nameservers = lib.mkForce ["127.0.0.55"]; # use blocky
    networkmanager.dns = lib.mkForce "none"; # use local resolver only
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    resolved = {
      enable = lib.mkForce true; # binds to port dns:127.0.0.53 and dns-proxy:127.0.0.54
      dnssec = "false"; # XXX disable dnssec for the clowns pointless mitm
      extraConfig = lib.mkForce "MulticastDNS=false\nCache=true\nCacheFromLocalhost=true\nDomains=~.";
      fallbackDns = lib.mkForce ["127.0.0.55"]; # use blocky as upstream @ 127.0.0.55
    };
  };

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
        ports.dns = "127.0.0.55:53";
        log.level = "info";
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
              "tcp+udp:192.168.0.1"
              "tcp+udp:192.168.1.1"
              "tcp+udp:192.168.80.1"
              "tcp+udp:9.9.9.9"
              "tcp+udp:9.9.9.10"
            ];
          };
        };
        bootstrapDns = [
          "tcp+udp:192.168.0.1"
          "tcp+udp:192.168.1.1"
          "tcp+udp:192.168.80.1"
          "tcp+udp:9.9.9.9"
          "tcp+udp:9.9.9.10"
        ];
        caching = {
          cacheTimeNegative = "30m";
          minTime = "2h";
          maxTime = "24h";
          maxItemsCount = 0;
          prefetching = true;
          prefetchExpires = "72h";
          prefetchThreshold = 1;
          prefetchMaxItemsCount = 0;
        };
      };
    };
  };
}
