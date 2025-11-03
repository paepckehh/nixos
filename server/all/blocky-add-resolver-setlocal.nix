{lib, ...}: {
  ##############
  #-=# INFO #=-#
  ##############
  # reconfigures blocky to use localhost resolver @ (ip: 127.0.0.56 port:53) as upstream resolver
  # do not include this flake as direct import, use:
  # add as recursive rootdns server resolver   => unbound          => add-[filter|cache]-resolver-unbound.nix
  # add as privacy resolver                    => dnscrypt-proxy   => add-[filter|cache]-resolver-dnscrypt-proxy.nix

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        upstreams = {
          init.strategy = lib.mkForce "fast";
          timeout = lib.mkForce "5s";
          strategy = lib.mkForce "strict";
          groups = {
            default = lib.mkForce [
              "tcp+udp:127.0.0.56"
              "tcp+udp:127.0.0.56"
            ];
          };
        };
      };
    };
  };
}
