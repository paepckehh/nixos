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
              url = "https://iss.admin.lan";
              user = "read-only-account";
              pass = /etc/nixos/server/resources/unifi.txt;
            }
          ];
        };
      };
    };
    static-web-server = {
      enable = false;
      listen = "10.0.0.30:9090";
      root = "/var/www";
      configuration = {
        general = {
          directory-listing = true;
        };
      };
    };
    dhcpd4 = {
      enable = false;
      interfaces = ["vlan1"];
      extraConfig = ''
        option domain-name-servers 10.0.0.30, 10.0.0.30;
        option subnet-mask 255.255.255.0;

        subnet 10.0.0.0 netmask 255.255.255.0 {
          option broadcast-address 10.0.0.255;
          option routers 10.0.0.254;
          interface vlan1;
          range 10.0.0.150 10.0.0.200;
        }
      '';
    };
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
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [53 9090];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.tmpfiles.rules = [
    "d /var/www 0755 root users"
  ];
}
