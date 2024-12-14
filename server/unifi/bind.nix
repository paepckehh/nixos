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
          bindURI = "http://localhost:8053/";
        };
      };
    };
    bind = {
      enable = true;
      cacheNetworks = ["127.0.0.0/24"];
      listenOn = ["10.0.0.2" "10.0.0.3" "10.0.8.2" "10.0.8.3" "10.0.16.2" "10.0.16.3" "10.0.128.2" "10.0.128.3" "10.0.250.2" "10.0.250.3"];
      ipv4Only = true;
      forward = "only";
      forwarders = ["127.0.0.1"];
      zones = {
        #########
        ## lan ##
        #########
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
        ##############
        ## home.lan ##
        ##############
        "home.lan" = {
          master = true;
          file = pkgs.writeText "lan" ''
            $ORIGIN home.lan.
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
        ###############
        ## infra.lan ##
        ###############
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
            unifi-ux             IN   A    10.0.0.110
            unifi-usw-flex-mini  IN   A    10.0.0.120
          '';
        };
        "0.0.10.in-addr.arap" = {
          master = true;
          file = pkgs.writeText "0.0.10.in-addr.arpa" ''
            $ORIGIN 0.0.10.in-addr.arpa.
            $TTL    1h
            @            IN      SOA     ns1 hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns1.lan.
                         IN      NS      ns2.lan.
            2            IN      PTR     ns1.lan.
            3            IN      PTR     ns2.lan.
            30           IN      PTR     nixos-mp-infra.infra.lan.
            110          IN      PTR     unifi-ux.infra.lan.
            120          IN      PTR     unifi-usw-flex-mini.infra.lan.
          '';
        };
        ###############
        ## admin.lan ##
        ###############
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
            ns1             IN   A    10.0.8.2
            ns2             IN   A    10.0.8.3
            nixos-mp-infra  IN   A    10.0.8.30
          '';
        };
        "8.0.10.in-addr.arap" = {
          master = true;
          file = pkgs.writeText "8.0.10.in-addr.arpa" ''
            $ORIGIN 8.0.10.in-addr.arpa.
            $TTL    1h
            @       IN   SOA             ns1 hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns1.admin.lan.
                         IN      NS      ns2.admin.lan.
            2            IN      PTR     ns1.admin.lan.
            3            IN      PTR     ns2.admin.lan.
            30           IN      PTR     nixos-mp-infra.admin.lan.
          '';
        };
        #####################
        ## server.home.lan ##
        #####################
        "server.home.lan" = {
          master = true;
          file = pkgs.writeText "server.home.lan" ''
            $ORIGIN server.home.lan.
            $TTL    1h
            @                IN   SOA ns1 hostmaster (
                                          1    ; Serial
                                          3h   ; Refresh
                                          1h   ; Retry
                                          1w   ; Expire
                                          1h)  ; Negative Cache TTL
                             IN   NS  ns1
                             IN   NS  ns2
            ns1              IN   A   10.0.16.2
            ns2              IN   A   10.0.16.3
            nixos-mp-infra   IN   A   10.0.16.30
          '';
        };
        "16.0.10.in-addr.arap" = {
          master = true;
          file = pkgs.writeText "16.0.10.in-addr.arpa" ''
            $ORIGIN 16.0.10.in-addr.arpa.
            $TTL    1h
            @            IN      SOA     ns1 hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns1.server.home.lan.
                         IN      NS      ns2.server.home.lan.
            2            IN      PTR     ns1.server.home.lan.
            3            IN      PTR     ns2.server.home.lan.
            30           IN      PTR     nixos-mp-infra.server.home.lan
          '';
        };
        #####################
        ## client.home.lan ##
        #####################
        "client.home.lan" = {
          master = true;
          file = pkgs.writeText "client.home.lan" ''
            $ORIGIN client.home.lan.
            $TTL    1h
            @                IN   SOA ns1 hostmaster (
                                          1    ; Serial
                                          3h   ; Refresh
                                          1h   ; Retry
                                          1w   ; Expire
                                          1h)  ; Negative Cache TTL
                             IN   NS  ns1
                             IN   NS  ns2
            ns1              IN   A   10.0.128.2
            ns2              IN   A   10.0.128.3
            nixos-mp-infra   IN   A   10.0.128.30
          '';
        };
        "128.0.10.in-addr.arap" = {
          master = true;
          file = pkgs.writeText "128.0.10.in-addr.arpa" ''
            $ORIGIN 128.0.10.in-addr.arpa.
            $TTL    1h
            @            IN      SOA     ns1 hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns1.client.home.lan.
                         IN      NS      ns2.client.home.lan.
            2            IN      PTR     ns1.client.home.lan.
            3            IN      PTR     ns2.client.home.lan.
            30           IN      PTR     nixos-mp-infra.client.home..lan
          '';
        };
        #############
        ## iot.lan ##
        #############
        "iot.lan" = {
          master = true;
          file = pkgs.writeText "iot.lan" ''
            $ORIGIN iot.lan.
            $TTL    1h
            @                            IN   SOA  ns1 hostmaster (
                                                       1    ; Serial
                                                       3h   ; Refresh
                                                       1h   ; Retry
                                                       1w   ; Expire
                                                       1h)  ; Negative Cache TTL
                                         IN   NS   ns1
                                         IN   NS   ns2
            ns1                          IN   A    10.0.250.2
            ns2                          IN   A    10.0.250.3
            nixos-mp-infra               IN   A    10.0.250.30
            eco-powerstream              IN   A    10.0.250.100
            eco-delta2                   IN   A    10.0.250.110
            eco-sock-desk                IN   A    10.0.250.120
            eco-sock-desk2               IN   A    10.0.250.121
            eco-sock-catroaster          IN   A    10.0.250.122
            eco-sock-centralheater       IN   A    10.0.250.123
            eco-sock-windowheater        IN   A    10.0.250.124
            eco-sock-fridge              IN   A    10.0.250.125
            eco-sock-hotplate            IN   A    10.0.250.126
            eco-sock-roomba              IN   A    10.0.250.127
          '';
        };
        "250.0.10.in-addr.arap" = {
          master = true;
          file = pkgs.writeText "250.0.10.in-addr.arpa" ''
            $ORIGIN 250.0.10.in-addr.arpa.
            $TTL    1h
            @            IN      SOA     ns1 hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns1.iot.lan.
                         IN      NS      ns2.iot.lan.
            2            IN      PTR     ns1.iot.lan.
            3            IN      PTR     ns2.iot.lan.
            30           IN      PTR     nixos-mp-infra.iot.lan.
            100          IN      PTR     eco-powerstream.iot.lan.
            110          IN      PTR     eco-delta2.iot.iot.lan.
            120          IN      PTR     eco-sock-desk.iot.lan.
            121          IN      PTR     eco-sock-desk2.iot.lan.
            122          IN      PTR     eco-sock-catroaster.iot.lan.
            123          IN      PTR     eco-sock-centralheater.iot.lan.
            124          IN      PTR     eco-sock-windowheater.iot.lan.
            125          IN      PTR     eco-sock-fridge.iot.lan.
            126          IN      PTR     eco-sock-hotplate.iot.lan.
            127          IN      PTR     eco-sock-roomba.iot.lan.
          '';
        };
      };
    };
  };
}
