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
      allowedUDPPorts = [67];
      allowedTCPPorts = [];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      exporters = {
        kea = {
          enable = false;
          targets = [
            "/run/kea/kea-dhcp4.socket"
          ];
        };
      };
    };
    kea.dhcp4 = {
      enable = true;
      settings = {
        authoritative = true;
        rebind-timer = 2000;
        renew-timer = 1000;
        valid-lifetime = 4000;
        interfaces-config = {
          interfaces = ["eth0"];
          dhcp-socket-type = "raw";
          service-sockets-max-retries = 5;
          service-sockets-retry-wait-time = 5000;
        };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        subnet4 = [
          {
            id = 1;
            comment = "infra.lan";
            subnet = "10.0.0.0/24";
            interface = "eth0";
            pools = [{pool = "10.0.0.200 - 10.0.0.249";}];
            option-data = [
              {
                name = "domain-name";
                data = "infra.lan";
              }
              {
                name = "domain-name-servers";
                data = "10.0.0.3, 10.0.0.2";
              }
              {
                name = "time-servers";
                data = "10.0.0.3, 10.0.0.2";
              }
            ];
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                hw-address = "00:ec:4c:36:08:63";
                ip-address = "10.0.0.30";
              }
              {
                hostname = "unifi-ux";
                hw-address = "28:70:4e:ff:ff:ff";
                ip-address = "10.0.0.110";
              }
              {
                hostname = "unifi-usw-flex-mini";
                hw-address = "28:70:4e:c2:de:a8";
                ip-address = "10.0.0.120";
              }
            ];
          }
          {
            id = 8;
            comment = "admin.home.lan";
            subnet = "10.0.8.0/24";
            interface = "eth0";
            pools = [{pool = "10.0.8.200 - 10.0.8.249";}];
            option-data = [
              {
                name = "domain-name";
                data = "admin.home.lan";
              }
              {
                name = "domain-name-servers";
                data = "10.0.8.3, 10.0.8.2";
              }
              {
                name = "time-servers";
                data = "10.0.8.3, 10.0.8.2";
              }
            ];
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                ip-address = "10.0.8.30";
                hw-address = "00:ec:4c:36:08:63";
              }
            ];
          }
          {
            id = 16;
            comment = "server.home.lan";
            subnet = "10.0.16.0/24";
            interface = "eth0";
            pools = [{pool = "10.0.16.200 - 10.0.16.249";}];
            option-data = [
              {
                name = "routers";
                data = "10.0.16.1";
              }
              {
                name = "domain-name";
                data = "server.home.lan";
              }
              {
                name = "domain-name-servers";
                data = "10.0.16.3, 10.0.16.2";
              }
              {
                name = "time-servers";
                data = "10.0.16.3, 10.0.16.2";
              }
            ];
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                ip-address = "10.0.8.30";
                hw-address = "00:ec:4c:36:08:63";
              }
            ];
          }
          {
            id = 128;
            comment = "client.home.lan";
            subnet = "10.0.9.0/24";
            interface = "eth0";
            pools = [{pool = "10.0.128.200 - 10.0.128.249";}];
            option-data = [
              {
                name = "routers";
                data = "10.0.128.1";
              }
              {
                name = "domain-name";
                data = "client.home.lan";
              }
              {
                name = "domain-name-servers";
                data = "10.0.128.3, 10.0.128.2";
              }
              {
                name = "time-servers";
                data = "10.0.128.3, 10.0.128.2";
              }
            ];
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                ip-address = "10.0.128.30";
                hw-address = "00:ec:4c:36:08:63";
              }
            ];
          }
          {
            id = 250;
            comment = "iot.home.lan";
            subnet = "10.0.250.0/24";
            interface = "eth0";
            pools = [{pool = "10.0.250.200 - 10.0.250.249";}];
            option-data = [
              {
                name = "routers";
                data = "10.0.250.1";
              }
              {
                name = "domain-name";
                data = "iot.home.lan";
              }
              {
                name = "domain-name-servers";
                data = "10.0.250.3, 10.0.250.2";
              }
              {
                name = "time-servers";
                data = "10.0.250.3, 10.0.250.2";
              }
            ];
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                ip-address = "10.0.250.30";
                hw-address = "00:ec:4c:36:08:63";
              }
              {
                hostname = "eco-powerstream";
                ip-address = "10.0.250.100";
                hw-address = "40:4c:ca:e9:b6:3c";
              }
              {
                hostname = "eco-delta2";
                ip-address = "10.0.250.110";
                hw-address = "dc:54:75:9b:1d:04";
              }
              {
                hostname = "eco-sock-desk";
                ip-address = "10.0.250.120";
                hw-address = "40:4C:ca:ba:fc:6c";
              }
              {
                hostname = "eco-sock-desk2";
                ip-address = "10.0.250.121";
                hw-address = "40:4C:ca:b9:54:70";
              }
              {
                hostname = "eco-sock-catroaster";
                ip-address = "10.0.250.122";
                hw-address = "40:4C:ca:c5:a8:f4";
              }
              {
                hostname = "eco-sock-centralheater";
                ip-address = "10.0.250.123";
                hw-address = "40:4c:ca:c4:7a:0c";
              }
              {
                hostname = "eco-sock-windowheater";
                ip-address = "10.0.250.124";
                hw-address = "40:4c:ca:aa:42:54";
              }
              {
                hostname = "eco-sock-fridge";
                ip-address = "10.0.250.125";
                hw-address = "ec:da:3b:a9:fa:64";
              }
              {
                hostname = "eco-sock-hotplate";
                ip-address = "10.0.250.126";
                hw-address = "ec:da:3b:aa:3a:fc";
              }
              {
                hostname = "eco-sock-roomba";
                ip-address = "10.0.250.127";
                hw-address = "ec:da:3b:af:12:dc";
              }
            ];
          }
        ];
      };
    };
  };
}
