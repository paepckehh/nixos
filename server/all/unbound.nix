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
          access-control = ["127.0.0.1/8 allow"];
          aggressive-nsec = true;
          cache-max-ttl = 86400;
          cache-min-ttl = 360;
          do-ip4 = true;
          do-ip6 = false;
          do-not-query-localhost = true;
          do-tcp = true;
          do-udp = true;
          edns-buffer-size = 1232;
          harden-algo-downgrade = true;
          harden-below-nxdomain = true;
          harden-dnssec-stripped = true;
          harden-glue = true;
          harden-large-queries = true;
          harden-short-bufsize = true;
          hide-identity = true;
          hide-version = true;
          incoming-num-tcp = 250;
          infra-cache-slabs = 4;
          interface = ["127.0.0.56"]; # 127.0.0.53/54 is taken by systemd-resolverd
          key-cache-slabs = 4;
          # logfile = "/var/lib/unbound/unbound.log";
          log-local-actions = true;
          log-queries = true;
          log-replies = true;
          log-servfail = true;
          log-time-ascii = true;
          log-time-iso = true;
          minimal-responses = true;
          module-config = "iterator"; # XXX disable dnssec for the clowns pointless mitm
          msg-cache-size = 142768128;
          msg-cache-slabs = 4;
          num-queries-per-thread = 4096;
          num-threads = 4;
          outgoing-range = 8192;
          port = 53;
          prefer-ip6 = false;
          prefetch-key = true;
          prefetch = true;
          qname-minimisation = true;
          ratelimit = 1000;
          rrset-cache-size = 285536256;
          rrset-cache-slabs = 4;
          rrset-roundrobin = true;
          serve-expired = true;
          so-reuseport = true;
          use-caps-for-id = false;
          use-syslog = true;
          # val-permissive-mode = true;  # XXX allow pass dnssec failed answers for the idiotic & pointless mitm
          verbosity = 2;
        };
      };
    };
  };
}
