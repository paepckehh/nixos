# DNS => BIND: bind authorative dns server, providing all dns zones, external forward
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
    nameservers = lib.mkForce [infra.dns.ip];
    networkmanager.insertNameservers = [infra.dns.ip];
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
    resolved = {
      enable = true;
      domains = [infra.domain.user infra.domain.tld];
      dnssec = lib.mkForce "true";
      extraConfig = "MulticastDNS=false\nCache=true\nCacheFromLocalhost=true\nDomains=~.\n";
      fallbackDns = [infra.dns.ip];
    };
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
      # forwarders = lib.mkForce [];
      forwarders = lib.mkForce infra.dns.upstream;
      forward = "first"; # how to handle external lookups, only - forward all to upstream dns server, first - allow recursive resolve if upstream fail
      ipv4Only = true;
      listenOn = [infra.dns.ip];
      listenOnPort = infra.dns.port;
      extraOptions = ''dnssec-validation auto;'';
      zones = {
        "${infra.domain.domain}" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.domain}.db" ''
            $ORIGIN ${infra.domain.domain}.
            $TTL    1h
            @ IN SOA ${infra.dns.fqdn}. ${infra.dns.contact}. (
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
            @ IN SOA ${infra.dns.fqdn}. ${infra.dns.contact}. (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                                      IN   NS   ${infra.dns.fqdn}.
            ${infra.dns.fqdn}         IN   A    ${infra.dns.ip}
            ${infra.pki.hostname}     IN   A    ${infra.pki.ip}
            ${infra.webacme.hostname} IN   A    ${infra.webacme.ip}
            ${infra.webmtls.hostname} IN   A    ${infra.webmtls.ip}
            ${infra.webpki.hostname}  IN   A    ${infra.webpki.ip}
          '';
        };
        "${infra.domain.user}" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.user}" ''
            $ORIGIN ${infra.domain.user}.
            $TTL    1h
            @ IN SOA ${infra.dns.fqdn}. ${infra.dns.contact}. (
                                           1    ; Serial
                                           3h   ; Refresh
                                           1h   ; Retry
                                           1w   ; Expire
                                           1h)  ; Negative Cache TTL
                                              IN NS ${infra.dns.fqdn}.
            ${infra.dns.hostname}             IN A  ${infra.dns.ip}
            ${infra.cache.hostname}           IN A  ${infra.cache.ip}
            ${infra.cloud.hostname}           IN A  ${infra.cloud.ip}
            ${infra.iam.hostname}             IN A  ${infra.iam.ip}
            ${infra.ldap.hostname}            IN A  ${infra.ldap.ip}
            ${infra.portal.hostname}          IN A  ${infra.portal.ip}
            ${infra.search.hostname}          IN A  ${infra.search.ip}
            ${infra.translate-lama.hostname}  IN A  ${infra.translate-lama.ip}
          '';
        };
        "${infra.domain.remote}" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.remote}" ''
            $ORIGIN ${infra.domain.remote}.
            $TTL    1h
            @ IN SOA ${infra.dns.fqdn}. ${infra.dns.contact}. (
                                           1    ; Serial
                                           3h   ; Refresh
                                           1h   ; Retry
                                           1w   ; Expire
                                           1h)  ; Negative Cache TTL
                                 IN NS ${infra.dns.fqdn}.
            ${infra.dns.fqdn}    IN A  ${infra.dns.ip}
          '';
        };
        "0.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arap" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "0.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa" ''
            $ORIGIN 0.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa.
            $TTL    1h
            @ IN SOA ${infra.dns.fqdn}. ${infra.dns.contact}. (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                                                IN NS  ${infra.dns.fqdn}.
            ${infra.dns.fqdn}                   IN A   ${infra.dns.ip}
            ${toString infra.cache.id}          IN PTR ${infra.cache.fqdn}.
            ${toString infra.iam.id}            IN PTR ${infra.iam.fqdn}.
            ${toString infra.ldap.id}           IN PTR ${infra.ldap.fqdn}.
            ${toString infra.pki.id}            IN PTR ${infra.pki.fqdn}.
            ${toString infra.portal.id}         IN PTR ${infra.portal.fqdn}.
            ${toString infra.search.id}         IN PTR ${infra.search.fqdn}.
            ${toString infra.webacme.id}        IN PTR ${infra.webacme.fqdn}.
            ${toString infra.webmtls.id}        IN PTR ${infra.webmtls.fqdn}.
            ${toString infra.webpki.id}         IN PTR ${infra.webpki.fqdn}.
            ${toString infra.translate-lama.id} IN PTR ${infra.translate-lama.fqdn}.
          '';
        };
      };
    };
  };
}
