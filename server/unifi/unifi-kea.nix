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
        option-def = [
          {
            name = "unifi-inform-host";
            code = 43;
            type = "string";
            # type = "ipv4-address";
            space = "dhcp4";
          }
        ];
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
              {
                name = "unifi-inform-host"; # custom-dhcp-option 43, details see option-def
                data = "http://10.0.0.30:8080/inform"; # unifi controller inform host url
                # data = "10.0.0.30"; # unifi controller inform host ipv4-address
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
                hostname = "unifi-express";
                hw-address = "94:2a:6f:1e:b0:c7";
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
                ip-address = "10.0.16.30";
                hw-address = "00:ec:4c:36:08:63";
              }
            ];
          }
          {
            id = 128;
            comment = "client.home.lan";
            subnet = "10.0.128.0/24";
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
