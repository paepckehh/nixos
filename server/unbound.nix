{
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./unbound-add-local-prometheus.nix
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  # networking.nameservers = ["127.0.0.1"];

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
          do-not-query-localhost = true;
          do-ip4 = true;
          do-ip6 = false;
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
          incoming-num-tcp = 50;
          infra-cache-slabs = 4;
          interface = ["127.0.0.1"];
          key-cache-slabs = 4;
          log-local-actions = true;
          log-queries = true;
          log-replies = true;
          log-servfail = true;
          logfile = "/var/lib/unbound/unbound.log";
          minimal-responses = true;
          msg-cache-size = 142768128;
          msg-cache-slabs = 4;
          num-queries-per-thread = 4096;
          num-threads = 4;
          outgoing-range = 8192;
          port = 5353; # XXX
          prefer-ip6 = false;
          prefetch-key = true;
          prefetch = true;
          ratelimit = 1000;
          rrset-cache-size = 285536256;
          rrset-cache-slabs = 4;
          rrset-roundrobin = true;
          serve-expired = true;
          so-reuseport = true;
          use-caps-for-id = false;
          use-syslog = false;
          verbosity = 3; # XXX
        };
        forward-zone = [
          {
            name = ".";
            forward-tls-upstream = true;
            forward-addr = [
              "9.9.9.9#dns.quad9.net"
              "149.112.112.112#dns.quad9.net"
            ];
          }
        ];
      };
    };
  };
}
