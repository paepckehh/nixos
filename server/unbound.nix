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
      settings = {
        server = {
          interface = ["127.0.0.1"];
          port = 5353; # XXX
          access-control = ["127.0.0.1/32 allow"];
          harden-glue = true;
          harden-dnssec-stripped = true;
          harden-large-queries = true;
          harden-short-bufsize = true;
          ratelimit = 1000;
          use-caps-for-id = false;
          prefetch = true;
          prefetch-key = true;
          serve-expired = true;
          so-reuseport = true;
          agressive-nsec = true;
          deny-any = true;
          do-not-query-localhost = true;
          prefer-ip6 = false;
          edns-buffer-size = 1232;
          hide-identity = true;
          hide-version = true;
        };
      };
    };
  };
}
