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
          dhcp-sock-type = "raw";
        };
        service-socks-max-retries = 10;
        service-socks-retry-wait-time = 120;
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        subnet4 = [
          {
            id = 1;
            comment = "infra.lan: unifi internal infrastructure";
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
                data = ["10.0.0.3" "10.0.0.2"];
              }
              {
                name = "time-servers";
                data = ["10.0.0.3" "10.0.0.2"];
              }
            ];
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                client-id = "00:ec:4c:36:08:63";
                ip-address = "10.0.0.30";
              }
              {
                hostname = "unifi-express-mphh";
                client-id = "28:70:4e:ff:ff:ff";
                ip-address = "10.0.0.110";
              }
              {
                hostname = "usw-flex-mini-mphh";
                client-id = "28:70:4e:c2:de:a8";
                ip-address = "10.0.0.120";
              }
            ];
          }
          {
            id = 4;
            comment = "admin.lan: administrative network";
            subnet = "10.0.4.0/24";
            interface = "eth0";
            pools = [{pool = "10.0.4.200 - 10.0.4.249";}];
            option-data = [
              {
                name = "domain-name";
                data = "admin.lan";
              }
              {
                name = "domain-name-servers";
                data = ["10.0.4.3" "10.0.4.2"];
              }
              {
                name = "time-servers";
                data = ["10.0.4.3" "10.0.4.2"];
              }
            ];
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                ip-address = "10.0.4.30";
                client-id = "00:ec:4c:36:08:63";
              }
            ];
          }
          {
            id = 8;
            comment = "intra.lan: intranet network";
            subnet = "10.0.8.0/24";
            interface = "eth0";
            pools = [{pool = "10.0.8.200 - 10.0.8.249";}];
            option-data = [
              {
                name = "routers";
                data = "10.0.8.1";
              }
              {
                name = "domain-name";
                data = "intra.lan";
              }
              {
                name = "domain-name-servers";
                data = ["10.0.8.1"];
              }
              {
                name = "time-servers";
                data = ["10.0.8.3" "10.0.8.2"];
              }
            ];
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                ip-address = "10.0.8.30";
                client-id = "00:ec:4c:36:08:63";
              }
            ];
          }
          {
            id = 9;
            comment = "iot.lan: iot internet of things";
            subnet = "10.0.9.0/24";
            interface = "eth0";
            pools = [{pool = "10.0.9.200 - 10.0.9.249";}];
            option-data = [
              {
                name = "routers";
                data = "10.0.9.1";
              }
              {
                name = "domain-name";
                data = "intra.lan";
              }
              {
                name = "domain-name-servers";
                data = ["10.0.9.3" "10.0.9.2"];
              }
              {
                name = "time-servers";
                data = ["10.0.9.3" "10.0.9.2"];
              }
            ];
            reservations-global = false;
            reservations-global = false;
            reservations-in-subnet = true;
            reservations-out-of-pool = false;
            reservations = [
              {
                hostname = "nixos-mp-infra";
                ip-address = "10.0.9.30";
                client-id = "00:ec:4c:36:08:63";
              }
              {
                hostname = "eco-powerstream-mp-hh";
                ip-address = "10.0.9.100";
                client-id = "40:4c:ca:e9:b6:3c";
              }
              {
                hostname = "eco-delta2-mp-hh";
                ip-address = "10.0.9.110";
                client-id = "dc:54:75:9b:1d:04";
              }
              {
                hostname = "eco-sock-desk-mp-hh";
                ip-address = "10.0.9.120";
                client-id = "40:4C:ca:ba:fc:6c";
              }
              {
                hostname = "eco-sock-desk2-mp-hh";
                ip-address = "10.0.9.121";
                client-id = "40:4C:ca:b9:54:70";
              }
              {
                hostname = "eco-sock-catroaster-mp-hh";
                ip-address = "10.0.9.122";
                client-id = "40:4C:ca:c5:a8:f4";
              }
              {
                hostname = "eco-sock-centralheater-mp-hh";
                ip-address = "10.0.9.123";
                client-id = " 40:4c:ca:c4:7a:0c";
              }
              {
                hostname = "eco-sock-windowheater-mp-hh";
                ip-address = "10.0.9.124";
                client-id = " 40:4c:ca:aa:42:54";
              }
              {
                hostname = "eco-sock-fridge-mp-hh";
                ip-address = "10.0.9.125";
                client-id = "ec:da:3b:a9:fa:64";
              }
              {
                hostname = "eco-sock-hotplate-mp-hh";
                ip-address = "10.0.9.126";
                client-id = "ec:da:3b:aa:3a:fc";
              }
              {
                hostname = "eco-sock-roomba-mp-hh";
                ip-address = "10.0.9.127";
                client-id = "ec:da:3b:af:12:dc";
              }
            ];
          }
        ];
      };
    };
  };
}
