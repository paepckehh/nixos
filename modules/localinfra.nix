{
  config,
  pkgs,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    vlans = {
      vlan001 = {
        id = 001;
        interface = "wlp2s0";
      };
    };
    interfaces.vlan001 = {
      virtual = true;
      ipv4.addresses = [
        {
          address = "10.0.0.30";
          prefixLength = 24;
        }
      ];
    };
    firewall = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [53];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    bind = {
      enable = true;
      listenOn = ["10.0.0.30"];
      ipv4Only = true; # cmd switch
      cacheNetworks = ["127.0.0.0/24"];
      extraOptions = "recursion no;";
      zones = {
        "lan" = {
          master = true;
          file = pkgs.writeText "lan" ''
            $ORIGIN lan.
            $TTL    1h
            @            IN      SOA     ns hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns
            ns           IN      A       10.0.0.30
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
            ns           IN      A       10.0.0.30
            firmware     IN      A       10.0.0.30
            nixbuilder   IN      A       10.0.0.30
          '';
        };
      };
    };
    dnsmasq = {
      enable = true;
      settings = {
        port = 0; # disable dns resolver
        dhcp-range = ["10.0.0.100,10.0.0.250"];
        dhcp-option = ["6,10.0.0.30"]; # 3 - gw, 4 - ntp, 6 - dns
        dhcp-leasefile = "/var/lib/dnsmasq/dnsmasq.leases";
      };
    };
  };
}