{
  config,
  pkgs,
  lib,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [53];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      exporters = {
        bind = {
          enable = false;
          bind-URI = "http://localhost:8053/";
        };
      };
    };
    bind = {
      enable = true;
      listenOn = ["10.0.0.2" "10.0.4.2" "10.0.8.2" "10.0.9.3" "10.0.0.3" "10.0.4.3" "10.0.8.3" "10.0.9.3"];
      ipv4Only = true;
      cacheNetworks = ["127.0.0.0/24"];
      extraOptions = "recursion no;";
      zones = {
        "lan" = {
          master = true;
          file = pkgs.writeText "lan" ''
            $ORIGIN lan.
            $TTL    1h
            @            IN      SOA     ns1 hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns1
                         IN      NS      ns2
            ns1          IN      A       10.0.0.2
            ns2          IN      A       10.0.0.3
          '';
        };
        "infra.lan" = {
          master = true;
          file = pkgs.writeText "infra.lan" ''
            $ORIGIN infra.lan.
            $TTL    1h
            @            IN      SOA  ns1  hostmaster (
                                           1    ; Serial
                                           3h   ; Refresh
                                           1h   ; Retry
                                           1w   ; Expire
                                           1h)  ; Negative Cache TTL
                                 IN   NS   ns1
                                 IN   NS   ns2
            ns1                  IN   A    10.0.0.2
            ns2                  IN   A    10.0.0.3
            nixos-mp-infra       IN   A    10.0.0.30
            unifi-ux-mphh        IN   A    10.0.0.110
            usw-flex-mini-mphh   IN   A    10.0.0.120
          '';
        };
        "admin.lan" = {
          master = true;
          file = pkgs.writeText "admin.lan" ''
            $ORIGIN admin.lan.
            $TTL    1h
            @               IN   SOA  ns1 hostmaster (
                                          1   ; Serial
                                          3h   ; Refresh
                                          1h   ; Retry
                                          1w   ; Expire
                                          1h)  ; Negative Cache TTL
                            IN   NS   ns1
                            IN   NS   ns2
            ns1             IN   A    10.0.4.2
            ns2             IN   A    10.0.4.3
            nixos-mp-infra  IN   A    10.0.4.30
          '';
        };
        "intra.lan" = {
          master = true;
          file = pkgs.writeText "intra.lan" ''
            $ORIGIN intra.lan.
            $TTL    1h
            @            IN      SOA  ns1 hostmaster (
                                          1    ; Serial
                                          3h   ; Refresh
                                          1h   ; Retry
                                          1w   ; Expire
                                          1h)  ; Negative Cache TTL
                             IN   NS  ns1
                             IN   NS  ns2
            ns1              IN   A   10.0.8.2
            ns2              IN   A   10.0.8.3
            nixos-mp-infra   IN   A   10.0.8.30
          '';
        };
        "iot.lan" = {
          master = true;
          file = pkgs.writeText "iot.lan" ''
            $ORIGIN iot.lan.
            $TTL    1h
            @                             IN   SOA   ns1 hostmaster (
                                                         1    ; Serial
                                                         3h   ; Refresh
                                                         1h   ; Retry
                                                         1w   ; Expire
                                                         1h)  ; Negative Cache TTL
                                           IN   NS   ns1
                                           IN   NS   ns2
            ns1                            IN   A    10.0.9.2
            ns2                            IN   A    10.0.9.3
            nixos-mp-infra                 IN   A    10.0.9.30
            eco-powerstream-mphh           IN   A    10.0.9.100
            eco-delta2-mphh                IN   A    10.0.9.110
            eco-socket-desk-mphh           IN   A    10.0.9.120
            eco-socket-desk2-mphh          IN   A    10.0.9.121
            eco-socket-catroaster-mphh     IN   A    10.0.9.122
            eco-socket-centralheater-mphh  IN   A    10.0.9.123
            eco-socket-windowheater-mphh   IN   A    10.0.9.124
            eco-socket-fridge-mphh         IN   A    10.0.9.125
            eco-socket-hotplate-mphh       IN   A    10.0.9.126
            eco-socket-roomba-mphh         IN   A    10.0.9.127
          '';
        };
      };
    };
  };
}
