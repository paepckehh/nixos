{
  config,
  lib,
  pkgs,
  ...
}: {
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
      settings = {
        log.level = "info";
        ports = {
          dns = "127.0.0.1:53";
          http = "127.0.0.1:9610"; # /metrics -> prometheus
        };
        upstreams = {
          timeout = "8s";
          strategy = "strict";
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
          prefetchExpires = "24h";
          prefetchThreshold = 1;
          prefetchMaxItemsCount = 0; # unlimited
        };
        prometheus = {
          enable = true;
          path = "/metrics";
        };
      };
    };
    dnscrypt-proxy2 = {
      enable = false;
      settings = {
        listen_addresses = ["127.0.0.1:5353"];
        max_clients = 250;
        ipv4_servers = true;
        ipv6_servers = true;
        dnscrypt_servers = true;
        doh_servers = true;
        odoh_servers = true;
        require_dnssec = true;
        require_nolog = true;
        require_nofilter = true;
        force_tcp = false;
        http3 = true;
        timeout = 8000;
        keepalive = 30;
        blocked_query_response = "refused";
        lb_strategy = "ph";
        lb_estimator = true;
        log_level = 2;
        use_syslog = true;
        cert_refresh_delay = 360;
        cert_ignore_timestamp = true;
        dnscrypt_ephemeral_keys = true;
        tls_disable_session_tickets = true;
        bootstrap_resolvers = ["192.168.8.1:53" "9.9.9.9:53"];
        ignore_system_dns = true;
        netprobe_timeout = 120;
        netprobe_address = "9.9.9.9:53";
        offline_mode = false;
        log_files_max_size = 10;
        log_files_max_age = 7;
        log_files_max_backups = 1;
        block_ipv6 = true;
        block_unqualified = true;
        block_undelegated = true;
        reject_ttl = 60;
        cache = true;
        cache_size = 16384;
        cache_min_ttl = 3600;
        cache_max_ttl = 86400;
        cache_neg_min_ttl = 3600;
        cache_neg_max_ttl = 3600;
      };
    };
  };
}
