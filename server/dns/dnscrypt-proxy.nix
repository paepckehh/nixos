{
  ##############
  #-=# INFO #=-#
  ##############
  # provides anon/privacy dnscrypt resolver on localhost ip:127.0.0.53 port:55 [tcp|udp]

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases."log.dns.dnscrypt" = ''sudo tail -n 1500 -f /var/lib/dnscrypt-proxy/query.log) |  bat --force-colorization --language syslog --paging never'';

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        listen_addresses = ["127.0.0.53:55"];
        max_clients = 250;
        ipv4_servers = true;
        ipv6_servers = false;
        dnscrypt_servers = true;
        doh_servers = false;
        odoh_servers = false;
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
        log_level = 1;
        use_syslog = true;
        cert_refresh_delay = 360;
        cert_ignore_timestamp = true;
        dnscrypt_ephemeral_keys = true;
        tls_disable_session_tickets = true;
        bootstrap_resolvers = ["192.168.0.1:53" "192.168.1.1:53" "192.168.8.1:53" "9.9.9.9:53" "9.9.9.10:53"];
        ignore_system_dns = true;
        netprobe_timeout = 120;
        netprobe_address = "9.9.9.9:53";
        offline_mode = false;
        block_ipv6 = true;
        block_unqualified = true;
        block_undelegated = true;
        reject_ttl = 60;
        cache = true;
        cache_size = 32768;
        cache_min_ttl = 3600;
        cache_max_ttl = 86400;
        cache_neg_min_ttl = 3600;
        cache_neg_max_ttl = 3600;
        query_log.file = "/var/lib/dnscrypt-proxy/query.log";
        sources = {
          public-resolvers = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
              "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
            ];
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
            cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
            refresh_delay = 72;
          };
          relays = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
              "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
            ];
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
            cache_file = "/var/lib/dnscrypt-proxy/relays.md";
            refresh_delay = 74;
          };
        };
        anonymized_dns.routes = [
          {
            server_name = "*";
            via = ["*"];
          }
        ];
      };
    };
  };
}
