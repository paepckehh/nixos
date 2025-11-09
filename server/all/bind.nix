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

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.bind = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
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
      forwarders = lib.mkForce infra.dns.upstream; # lib.mkForce []; for recursive only
      forward = "first"; # how to handle external lookups, only - forward all to upstream dns server, first - allow recursive resolve if upstream fail
      ipv4Only = true;
      listenOn = [infra.dns.ip infra.localhost.ip];
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
                                      IN NS   ${infra.dns.fqdn}.
            ${infra.dns.fqdn}         IN A    ${infra.dns.ip}
            ${infra.pki.hostname}     IN A    ${infra.pki.ip}
            ${infra.webacme.hostname} IN A    ${infra.webacme.ip}
            ${infra.webmtls.hostname} IN A    ${infra.webmtls.ip}
            ${infra.webpki.hostname}  IN A    ${infra.webpki.ip}
            ${infra.webacme.hostname} IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.webacme.ip}"
            ${infra.webmtls.hostname} IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.webmtls.ip}"
            ${infra.webpki.hostname}  IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.webpki.ip}"
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
            ${infra.autoconfig.hostname}      IN A  ${infra.autoconfig.ip}
            ${infra.cache.hostname}           IN A  ${infra.cache.ip}
            ${infra.cloud.hostname}           IN A  ${infra.cloud.ip}
            ${infra.dns.hostname}             IN A  ${infra.dns.ip}
            ${infra.grist.hostname}           IN A  ${infra.grist.ip}
            ${infra.iam.hostname}             IN A  ${infra.iam.ip}
            ${infra.it.hostname}              IN A  ${infra.it.ip}
            ${infra.imap.hostname}            IN A  ${infra.imap.ip}
            ${infra.ldap.hostname}            IN A  ${infra.ldap.ip}
            ${infra.sso.hostname}             IN A  ${infra.sso.ip}
            ${infra.smtp.hostname}            IN A  ${infra.smtp.ip}
            ${infra.portal.hostname}          IN A  ${infra.portal.ip}
            ${infra.res.hostname}             IN A  ${infra.res.ip}
            ${infra.search.hostname}          IN A  ${infra.search.ip}
            ${infra.test.hostname}            IN A  ${infra.test.ip}
            ${infra.translate-lama.hostname}  IN A  ${infra.translate-lama.ip}
            ${infra.webmail.hostname}         IN A  ${infra.webmail.ip}
            ${infra.autoconfig.hostname}      IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.webmail.ip}"
            ${infra.cache.hostname}           IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.cache.ip}"
            ${infra.cloud.hostname}           IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.cloud.ip}"
            ${infra.grist.hostname}           IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.grist.ip}"
            ${infra.iam.hostname}             IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.iam.ip}"
            ${infra.it.hostname}              IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.it.ip}"
            ${infra.ldap.hostname}            IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.ldap.ip}"
            ${infra.sso.hostname}             IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.sso.ip}"
            ${infra.portal.hostname}          IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.portal.ip}"
            ${infra.res.hostname}             IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.res.ip}"
            ${infra.search.hostname}          IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.search.ip}"
            ${infra.test.hostname}            IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.test.ip}"
            ${infra.translate-lama.hostname}  IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.translate-lama.ip}"
            ${infra.webmail.hostname}         IN HTTPS 1 . alpn="h3,h2" ipv4hint="${infra.webmail.ip}"
            _autodiscover._tcp                IN SRV 0 0 443 ${infra.autoconfig.fqdn}.
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
        "0.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa" = {
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
            ${toString infra.autoconfig.id}     IN PTR ${infra.autoconfig.fqdn}.
            ${toString infra.cache.id}          IN PTR ${infra.cache.fqdn}.
            ${toString infra.iam.id}            IN PTR ${infra.iam.fqdn}.
            ${toString infra.it.id}             IN PTR ${infra.it.fqdn}.
            ${toString infra.imap.id}           IN PTR ${infra.imap.fqdn}.
            ${toString infra.ldap.id}           IN PTR ${infra.ldap.fqdn}.
            ${toString infra.pki.id}            IN PTR ${infra.pki.fqdn}.
            ${toString infra.portal.id}         IN PTR ${infra.portal.fqdn}.
            ${toString infra.search.id}         IN PTR ${infra.search.fqdn}.
            ${toString infra.smtp.id}           IN PTR ${infra.smtp.fqdn}.
            ${toString infra.res.id}            IN PTR ${infra.res.fqdn}.
            ${toString infra.translate-lama.id} IN PTR ${infra.translate-lama.fqdn}.
            ${toString infra.webacme.id}        IN PTR ${infra.webacme.fqdn}.
            ${toString infra.webmtls.id}        IN PTR ${infra.webmtls.fqdn}.
            ${toString infra.webpki.id}         IN PTR ${infra.webpki.fqdn}.
            ${toString infra.webmail.id}        IN PTR ${infra.webmail.fqdn}.
          '';
        };
      };
      extraConfig = ''
         logging {
         channel default_log {
             file "/var/run/named/default" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
         };
         channel auth_servers_log {
             file "/var/run/named/auth_servers" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
         };
         channel dnssec_log {
             file "/var/run/named/dnssec" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
        };
        channel zone_transfers_log {
             file "/var/run/named/zone_transfers" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
        };
        channel ddns_log {
             file "/var/run/named/ddns" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
        };
        channel client_security_log {
             file "/var/run/named/client_security" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
        };
        channel rate_limiting_log {
             file "/var/run/named/rate_limiting" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
        };
        channel rpz_log {
             file "/var/run/named/rpz" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
        };
        channel dnstap_log {
             file "/var/run/named/dnstap" versions 5 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
        };
        channel queries_log {
             file "/var/run/named/queries" versions 10 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity info;
        };
        channel query-errors_log {
             file "/var/run/named/query-errors" versions 10 size 20m;
             print-time yes;
             print-category yes;
             print-severity yes;
             severity dynamic;
        };
        channel default_syslog {
             print-time yes;
             print-category yes;
             print-severity yes;
             syslog daemon;
             severity info;
        };
        channel default_debug {
             print-time yes;
             print-category yes;
             print-severity yes;
             file "named.run";
             severity dynamic;
        };
        category default { default_syslog; default_debug; default_log; };
        category config { default_syslog; default_debug; default_log; };
        category dispatch { default_syslog; default_debug; default_log; };
        category network { default_syslog; default_debug; default_log; };
        category general { default_syslog; default_debug; default_log; };
        category zoneload { default_syslog; default_debug; default_log; };
        category resolver { auth_servers_log; default_debug; };
        category cname { auth_servers_log; default_debug; };
        category lame-servers { auth_servers_log; default_debug; };
        category edns-disabled { auth_servers_log; default_debug; };
        category dnssec { dnssec_log; default_debug; };
        category notify { zone_transfers_log; default_debug; };
        category xfer-in { zone_transfers_log; default_debug; };
        category xfer-out { zone_transfers_log; default_debug; };
        category update{ ddns_log; default_debug; };
        category update-security { ddns_log; default_debug; };
        category client{ client_security_log; default_debug; };
        category security { client_security_log; default_debug; };
        category rate-limit { rate_limiting_log; default_debug; };
        category spill { rate_limiting_log; default_debug; };
        category database { rate_limiting_log; default_debug; };
        category rpz { rpz_log; default_debug; };
        category dnstap { dnstap_log; default_debug; };
        category trust-anchor-telemetry { default_syslog; default_debug; default_log; };
        category queries { queries_log; };
        category query-errors {query-errors_log; };
        };'';
    };
  };
}
