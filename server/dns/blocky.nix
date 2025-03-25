{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [
  #  ./add-local-prometheus.nix
  #  ./add-local-redis-cache.nix
  # ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.nameservers = ["127.0.0.1"];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      enable = true;
      package = pkgs.unstable.blocky;
      settings = {
        log.level = "info";
        ports.dns = "127.0.0.1:53";
        upstreams = {
          timeout = "8s";
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
            iot = ["smartTV"];
            default = ["ads" "scam" "porn" "malware"];
          };
        };
        caching = {
          cacheTimeNegative = "1m";
          minTime = "2h";
          maxTime = "24h";
          maxItemsCount = 0; # unlimited
          prefetching = true;
          prefetchExpires = "72h";
          prefetchThreshold = 1;
          prefetchMaxItemsCount = 0; # unlimited
        };
        queryLog = {
          type = "csv";
          target = "/var/lib/blocky";
          logRetentionDays = 180;
          creationAttempts = 128;
          creationCooldown = "10s";
          flushInterval = "60s";
        };
      };
    };
  };
}
