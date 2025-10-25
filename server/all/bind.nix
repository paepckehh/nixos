{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/home.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.dns.ip} ${infra.dns.hostname} ${infra.dns.fqdn}.";
    firewall = {
      allowedTCPPorts = [infra.dns.port];
      allowedUDPPorts = [infra.dns.port];
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
          bindURI = "http://${infra.localhost.ip}:${toString infra.metric.port.offset + infra.dns.id}";
        };
      };
    };
    bind = {
      enable = true;
      cacheNetworks = infra.dns.accessArray;
      forward = "only"; # how to handle external lookups, only - forward all to upstream dns server, first - allow recursive resolve if upstream fail
      forwarders = config.networking.nameservers;
      ipv4Only = true;
      listenOn = [infra.dns.ip];
      listenOnPort = infra.dns.port;
      zones = {
        "${infra.domain.tld}" = {
          master = true;
          slaves = [infra.dns.ip]; # XXX TODO fix upstream
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.tld}.db" ''
            $ORIGIN corp.
            $TTL    1h
            @            IN      SOA     dns hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      dns
            dns          IN      A       ${infra.dns.ip}
          '';
        };
        "${infra.domain.domain}" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.domain}.db" ''
            $ORIGIN ${infra.domain.domain}.
            $TTL    1h
            @            IN      SOA     dns hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                         IN      NS      dns
            dns          IN      A       ${infra.dns.ip}
          '';
        };
        "${infra.domain.admin}" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.admin}.db" ''
            $ORIGIN ${infra.domain.admin}.
            $TTL    1h
            @            IN      SOA     dns hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                                 IN   NS   dns.corp.
            dns.corp             IN   A    ${infra.dns.ip}
          '';
        };
        "${infra.domain.user}" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.user}" ''
            $ORIGIN ${infra.domain.user}.
            $TTL    1h
            @            IN      SOA   dns hostmaster (
                                           1    ; Serial
                                           3h   ; Refresh
                                           1h   ; Retry
                                           1w   ; Expire
                                           1h)  ; Negative Cache TTL
                                 IN   NS   dns.corp.
            dns.corp             IN   A    ${infra.dns.ip}
            iam                  IN   A    ${infra.iam.ip}
            ldap                 IN   A    ${infra.ldap.ip}
          '';
        };
        "${infra.domain.remote}" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.remote}" ''
            $ORIGIN ${infra.domain.remote}.
            $TTL    1h
            @            IN      SOA   dns hostmaster (
                                           1    ; Serial
                                           3h   ; Refresh
                                           1h   ; Retry
                                           1w   ; Expire
                                           1h)  ; Negative Cache TTL
                                 IN   NS   dns.corp.
            dns.corp             IN   A    ${infra.dns.ip}
          '';
        };
        "0.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arap" = {
          master = true;
          slaves = [infra.dns.ip]; # XXX TODO fix upstream
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "0.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa" ''
            $ORIGIN 0.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa.
            $TTL    1h
            @            IN      SOA     dns hostmaster (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                                        IN      NS      dns.corp.
            dns.corp                    IN      A       ${infra.dns.ip}
            ${toString infra.dns.id}    IN      PTR     ${infra.dns.fqdn}.
            ${toString infra.iam.id}    IN      PTR     ${infra.iam.fqdn}.
            ${toString infra.ldap.id}   IN      PTR     ${infra.ldap.fqdn}.
          '';
        };
      };
    };
  };
}
