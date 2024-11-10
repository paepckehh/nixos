{
  config,
  pkgs,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    # vlans = {
    #   vlan001 = { id = 001; interface = "wlp2s0"; };
    #   vlan100 = { id = 100; interface = "wlp2s0"; };
    # };
    vswitches = {
      vs1.interfaces = {vlan001 = {};};
      vs2.interfaces = {vlan100 = {};};
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
    interfaces.vlan100 = {
      virtual = true;
      ipv4.addresses = [
        {
          address = "192.168.83.30";
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
      enable = false;
      cacheNetworks = ["127.0.0.0/24" "10.0.0.0/24"];
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

            ns1          IN      A       10.0.0.30
          '';
        };
        "infra.lan" = {
          master = true;
          file = pkgs.writeText "infra.lan" ''
            $ORIGIN infra.lan.
            $TTL    1h
            @            IN      SOA     ns1 hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      ns1

            ns1          IN      A       10.0.0.30
            firmware     IN      A       10.0.0.30
          '';
        };
      };
    };
    kea.dhcp4 = {
      enable = false;
      settings = ''
              {
          interfaces-config = {
            interfaces = [
              "vlan1"
            ];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          intra4 = [
            {
              subnet = "10.0.0.0/24";
              pools = [{ pool = "10.0.0.100 - 10.0.0.200"; }];
              option-data = [{ domain-name-servers = "10.0.0.30, 10.0.0.30"; }];
            }
          ];
          valid-lifetime = 4000;
        }'';
    };
  };
}
