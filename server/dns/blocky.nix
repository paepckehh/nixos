{pkgs, ...}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    nameservers = ["127.0.0.1" "192.168.8.1"];
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
        ports.dns = "127.0.0.1";
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
              # "tcp+udp:127.0.0.1:5353"
              "tcp+udp:192.168.8.1:53"
              "tcp-tls:hard.dnsforge.de:853"
              "tcp-tls:dns3.digitalcourage.de:853"
              "tcp-tls:fdns1.dismail.de:853"
              "tcp-tls:dns.quad9.net"
              "https://dns.digitale-gesellschaft.ch/dns-query"
              "https://dns.quad9.net/dns-query"
            ];
          };
        };
        bootstrapDns = [
          # "tcp+udp:127.0.0.1:5353"
          "tcp+udp:192.168.8.1:53"
          "tcp+udp:49.12.222.213"
          "tcp+udp:88.198.122.154"
          "tcp+udp:5.9.164.112"
          "tcp+udp:9.9.9.9"
        ];
        blocking = {
          blockType = "zeroIP";
          blockTTL = "15m";
          allowlists = {
            ads = [""];
          };
          denylists = {
            ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://blocklistproject.github.io/Lists/ads.txt"
              "https://blocklistproject.github.io/Lists/tracking.txt"
            ];
            scam = [
              "https://blocklistproject.github.io/Lists/scam.txt"
              "https://blocklistproject.github.io/Lists/redirect.txt"
            ];
            porn = [
              "https://blocklistproject.github.io/Lists/porn.txt"
            ];
            malware = [
              "https://blocklistproject.github.io/Lists/malware.txt"
              "https://blocklistproject.github.io/Lists/ransomware.txt"
              "https://blocklistproject.github.io/Lists/phishing.txt"
            ];
            smartTV = [
              "https://blocklistproject.github.io/Lists/smart-tv.txt"
            ];
          };
          clientGroupsBlock = {
            unblock = [];
            tv = ["smartTV"];
            default = ["ads" "scam" "porn" "malware"];
          };
        };
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
        # queryLog = {
        # type = "csv"; # needs nixos upstream bugfix PR388962
        # target = "/var/lib/blocky";
        # logRetentionDays = 180;
        # creationAttempts = 128;
        # creationCooldown = "10s";
        # flushInterval = "60s";
        # };
      };
    };
  };
}
