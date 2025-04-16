{lib, ...}: {
  ##############
  #-=# INFO #=-#
  ##############
  # reconfigures blocky to use localhost resolver @ (ip: 127.0.0.55 port:53) as upstream

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
              "tcp+udp:127.0.0.55"
              "tcp+udp:127.0.0.55"
            ];
          };
        };
      };
    };
  };
}
