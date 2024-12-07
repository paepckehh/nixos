{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    unifi = {
      enable = true;
      openFirewall = true;
    };
    prometheus = {
      exporters = {
        unpoller = {
          enable = false;
          controllers = [
            {
              url = "http://localhost:8443";
              user = "readonly";
              pass = "/etc/nixos/server/resources/unifi.txt";
            }
          ];
        };
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [53 67 68];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    kea.dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = ["eth0/10.0.0.30"];
          dhcp-socket-type = "udp";
        };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        rebind-timer = 2000;
        renew-timer = 1000;
        valid-lifetime = 4000;
        subnet4 = [
          {
            id = 1;
            subnet = "10.0.0.0/24";
            pools = [{pool = "10.0.0.220 - 10.0.0.240";}];
          }
        ];
      };
    };
    bind = {
      enable = true;
      listenOn = ["10.0.0.2" "10.0.0.3"];
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
            @            IN      SOA     ns hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns
            ns1          IN      A       10.0.0.2
            ns2          IN      A       10.0.0.3
            unifi        IN      A       10.0.0.30
          '';
        };
      };
    };
  };
}
