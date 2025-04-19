{
  ##############
  #-=# INFO #=-#
  ##############
  # provides recursive (plain-dns via root-dns-server) unbound outbound resolver on localhost ip:127.0.0.56 port:53 [tcp|udp]

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases."log.dns.unbound" = ''sudo tail -n 1500 -f /var/lib/unbound/unbound.log |  bat --force-colorization --language syslog --paging never'';

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    unbound = {
      enable = true;
      enableRootTrustAnchor = true;
      localControlSocketPath = "/run/unbound/unbound.ctl";
      settings = {
        server = {
          interface = ["127.0.0.56"];
          port = 53;
          use-syslog = true;
          verbosity = 3;
          access-control = ["127.0.0.1/8 allow"];
          module-config = "iterator"; # XXX disable dnssec for the clowns pointless mitm
          # val-permissive-mode = true;  # XXX allow pass dnssec failed answers for the idiotic & pointless mitm
          # aggressive-nsec = true;
          # cache-max-ttl = 86400;
          # cache-min-ttl = 360;
          # do-not-query-localhost = true;
          # do-ip4 = true;
          do-ip6 = false;
          # do-tcp = true;
          # do-udp = true;
          # edns-buffer-size = 1232;
          # harden-algo-downgrade = true;
          # harden-below-nxdomain = true;
          # harden-dnssec-stripped = true;
          # harden-glue = true;
          # harden-large-queries = true;
          # harden-short-bufsize = true;
          # hide-identity = true;
          # hide-version = true;
          # incoming-num-tcp = 50;
          # infra-cache-slabs = 4;
          # key-cache-slabs = 4;
          log-local-actions = true;
          log-queries = true;
          log-replies = true;
          log-servfail = true;
          logfile = "/var/lib/unbound/unbound.log";
          # minimal-responses = true;
          # msg-cache-size = 142768128;
          # msg-cache-slabs = 4;
          # num-queries-per-thread = 4096;
          # num-threads = 4;
          # outgoing-range = 8192;
          # prefer-ip6 = false;
          # prefetch-key = true;
          # prefetch = true;
          # ratelimit = 1000;
          # rrset-cache-size = 285536256;
          # rrset-cache-slabs = 4;
          # rrset-roundrobin = true;
          # serve-expired = true;
          # so-reuseport = true;
          # use-caps-for-id = false;
        };
      };
    };
  };
}
