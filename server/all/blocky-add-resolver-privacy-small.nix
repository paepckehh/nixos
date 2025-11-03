{
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        upstreams = {
          init.strategy = lib.mkForce "fast"; # blocking, failOnError, fast
          timeout = lib.mkForce "8s";
          strategy = lib.mkForce "random"; # strict, random, parallel_best (best two)
          groups = {
            default = lib.mkForce [
              "tcp-tls:hard.dnsforge.de:853"
              "tcp-tls:dns3.digitalcourage.de:853"
              "tcp-tls:fdns1.dismail.de:853"
              "tcp-tls:dns.quad9.net"
              "https://dns.digitale-gesellschaft.ch/dns-query"
              "https://dns.quad9.net/dns-query"
            ];
          };
        };
      };
    };
  };
}
