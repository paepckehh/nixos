{
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.nameservers = ["127.0.0.1"];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
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
