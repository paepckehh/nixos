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
      allowedTCPPorts = [infra.port.dns];
      allowedUDPPorts = [infra.port.dns];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.dns.ip}/32";}];
    services.bind = {
      after = ["sockets.target"];
      wants = ["sockets.target"];
      wantedBy = ["multi-user.target"];
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
                                                 IN NS ${infra.dns.fqdn}.
            ${infra.autoconfig.hostname}         IN A  ${infra.autoconfig.admin.ip}
            ${infra.databasement.fqdn}           IN A  ${infra.databasement.ip}
            ${infra.dns.fqdn}                    IN A  ${infra.dns.ip}
            ${infra.imap.hostname}               IN A  ${infra.imap.admin.ip}
            ${infra.smtp.hostname}               IN A  ${infra.smtp.admin.ip}
            ${infra.srv.hostname}                IN A  ${infra.srv.admin.ip}
            ${infra.pki.hostname}                IN A  ${infra.pki.ip}
            ${infra.proxmox.hostname}            IN A  ${infra.proxmox.ip}
            ${infra.ollama01.hostname}           IN A  ${infra.ollama01.ip}
            ${infra.webacme.hostname}            IN A  ${infra.webacme.ip}
            ${infra.webpki.hostname}             IN A  ${infra.webpki.ip}
            ${infra.autoconfig.hostname}         IN HTTPS 1 . alpn="h3" ipv4hint="${infra.autoconfig.admin.ip}"
            ${infra.databasement.hostname}       IN HTTPS 1 . alpn="h3" ipv4hint="${infra.databasement.ip}"
            ${infra.webacme.hostname}            IN HTTPS 1 . alpn="h3" ipv4hint="${infra.webacme.ip}"
            ${infra.webpki.hostname}             IN HTTPS 1 . alpn="h3" ipv4hint="${infra.webpki.ip}"
            _autodiscover._tcp                   IN SRV 0 0 443 ${infra.autoconfig.admin.fqdn}.
            _imap._tcp                           IN SRV 0 0 143 ${infra.imap.user.fqdn}.
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
            ${infra.autoconfig.hostname}         IN A  ${infra.autoconfig.user.ip}
            ${infra.bentopdf.hostname}           IN A  ${infra.bentopdf.ip}
            ${infra.cache.hostname}              IN A  ${infra.cache.ip}
            ${infra.chef.hostname}               IN A  ${infra.chef.ip}
            ${infra.coturn.hostname}             IN A  ${infra.coturn.ip}
            ${infra.dns.hostname}                IN A  ${infra.dns.ip}
            ${infra.donetick.hostname}           IN A  ${infra.donetick.ip}
            ${infra.dumbdrop.hostname}           IN A  ${infra.dumbdrop.ip}
            ${infra.ente.hostname}               IN A  ${infra.ente.ip}
            ${infra.erpnext.hostname}            IN A  ${infra.erpnext.ip}
            ${infra.grist.hostname}              IN A  ${infra.grist.ip}
            ${infra.glance.hostname}             IN A  ${infra.glance.ip}
            ${infra.iam.hostname}                IN A  ${infra.iam.ip}
            ${infra.it.hostname}                 IN A  ${infra.it.ip}
            ${infra.kimai.hostname}              IN A  ${infra.kimai.ip}
            ${infra.immich.hostname}             IN A  ${infra.immich.ip}
            ${infra.imap.hostname}               IN A  ${infra.imap.user.ip}
            ${infra.ldap.hostname}               IN A  ${infra.ldap.ip}
            ${infra.matrix.hostname}             IN A  ${infra.matrix.ip}
            ${infra.navidrome.hostname}          IN A  ${infra.navidrome.ip}
            ${infra.meshtastic-web.hostname}     IN A  ${infra.meshtastic-web.ip}
            ${infra.networking-toolbox.hostname} IN A  ${infra.networking-toolbox.ip}
            ${infra.nextcloud.hostname}          IN A  ${infra.nextcloud.ip}
            ${infra.miniflux.hostname}           IN A  ${infra.miniflux.ip}
            ${infra.portal.hostname}             IN A  ${infra.portal.ip}
            ${infra.undb.hostname}               IN A  ${infra.undb.ip}
            ${infra.onlyoffice.hostname}         IN A  ${infra.onlyoffice.ip}
            ${infra.rackula.hostname}            IN A  ${infra.rackula.ip}
            ${infra.res.hostname}                IN A  ${infra.res.ip}
            ${infra.search.hostname}             IN A  ${infra.search.ip}
            ${infra.sso.hostname}                IN A  ${infra.sso.ip}
            ${infra.srv.hostname}                IN A  ${infra.srv.user.ip}
            ${infra.smtp.hostname}               IN A  ${infra.smtp.user.ip}
            ${infra.smbgate.hostname}            IN A  ${infra.smbgate.ip}
            ${infra.test.hostname}               IN A  ${infra.test.ip}
            ${infra.timetrack.hostname}          IN A  ${infra.timetrack.ip}
            ${infra.translate.hostname}          IN A  ${infra.translate.ip}
            ${infra.vault.hostname}              IN A  ${infra.vault.ip}
            ${infra.vaultls.hostname}            IN A  ${infra.vaultls.ip}
            ${infra.webarchiv.hostname}          IN A  ${infra.webarchiv.ip}
            ${infra.webmail.hostname}            IN A  ${infra.webmail.ip}
            ${infra.websurfx.hostname}           IN A  ${infra.websurfx.ip}
            ${infra.web-check.hostname}          IN A  ${infra.web-check.ip}
            ${infra.wiki-go.hostname}            IN A  ${infra.wiki-go.ip}
            ${infra.zipline.hostname}            IN A  ${infra.zipline.ip}
            ${infra.autoconfig.hostname}         IN HTTPS 1 . alpn="h3" ipv4hint="${infra.autoconfig.user.ip}"
            ${infra.bentopdf.hostname}           IN HTTPS 1 . alpn="h3" ipv4hint="${infra.bentopdf.ip}"
            ${infra.cache.hostname}              IN HTTPS 1 . alpn="h3" ipv4hint="${infra.cache.ip}"
            ${infra.chef.hostname}               IN HTTPS 1 . alpn="h3" ipv4hint="${infra.chef.ip}"
            ${infra.donetick.hostname}           IN HTTPS 1 . alpn="h3" ipv4hint="${infra.donetick.ip}"
            ${infra.dumbdrop.hostname}           IN HTTPS 1 . alpn="h3" ipv4hint="${infra.dumbdrop.ip}"
            ${infra.ente.hostname}               IN HTTPS 1 . alpn="h3" ipv4hint="${infra.ente.ip}"
            ${infra.erpnext.hostname}            IN HTTPS 1 . alpn="h3" ipv4hint="${infra.erpnext.ip}"
            ${infra.grist.hostname}              IN HTTPS 1 . alpn="h3" ipv4hint="${infra.grist.ip}"
            ${infra.glance.hostname}             IN HTTPS 1 . alpn="h3" ipv4hint="${infra.glance.ip}"
            ${infra.iam.hostname}                IN HTTPS 1 . alpn="h3" ipv4hint="${infra.iam.ip}"
            ${infra.immich.hostname}             IN HTTPS 1 . alpn="h3" ipv4hint="${infra.immich.ip}"
            ${infra.it.hostname}                 IN HTTPS 1 . alpn="h3" ipv4hint="${infra.it.ip}"
            ${infra.kimai.hostname}              IN HTTPS 1 . alpn="h3" ipv4hint="${infra.kimai.ip}"
            ${infra.ldap.hostname}               IN HTTPS 1 . alpn="h3" ipv4hint="${infra.ldap.ip}"
            ${infra.matrix.hostname}             IN HTTPS 1 . alpn="h3" ipv4hint="${infra.matrix.ip}"
            ${infra.navidrome.hostname}          IN HTTPS 1 . alpn="h3" ipv4hint="${infra.navidrome.ip}"
            ${infra.meshtastic-web.hostname}     IN HTTPS 1 . alpn="h3" ipv4hint="${infra.meshtastic-web.ip}"
            ${infra.networking-toolbox.hostname} IN HTTPS 1 . alpn="h3" ipv4hint="${infra.networking-toolbox.ip}"
            ${infra.nextcloud.hostname}          IN HTTPS 1 . alpn="h3" ipv4hint="${infra.nextcloud.ip}"
            ${infra.miniflux.hostname}           IN HTTPS 1 . alpn="h3" ipv4hint="${infra.miniflux.ip}"
            ${infra.onlyoffice.hostname}         IN HTTPS 1 . alpn="h3" ipv4hint="${infra.onlyoffice.ip}"
            ${infra.portal.hostname}             IN HTTPS 1 . alpn="h3" ipv4hint="${infra.portal.ip}"
            ${infra.rackula.hostname}            IN HTTPS 1 . alpn="h3" ipv4hint="${infra.rackula.ip}"
            ${infra.res.hostname}                IN HTTPS 1 . alpn="h3" ipv4hint="${infra.res.ip}"
            ${infra.search.hostname}             IN HTTPS 1 . alpn="h3" ipv4hint="${infra.search.ip}"
            ${infra.sso.hostname}                IN HTTPS 1 . alpn="h3" ipv4hint="${infra.sso.ip}"
            ${infra.test.hostname}               IN HTTPS 1 . alpn="h3" ipv4hint="${infra.test.ip}"
            ${infra.timetrack.hostname}          IN HTTPS 1 . alpn="h3" ipv4hint="${infra.timetrack.ip}"
            ${infra.translate.hostname}          IN HTTPS 1 . alpn="h3" ipv4hint="${infra.translate.ip}"
            ${infra.vault.hostname}              IN HTTPS 1 . alpn="h3" ipv4hint="${infra.vault.ip}"
            ${infra.vaultls.hostname}            IN HTTPS 1 . alpn="h3" ipv4hint="${infra.vaultls.ip}"
            ${infra.webarchiv.hostname}          IN HTTPS 1 . alpn="h3" ipv4hint="${infra.webarchiv.ip}"
            ${infra.webmail.hostname}            IN HTTPS 1 . alpn="h3" ipv4hint="${infra.webmail.ip}"
            ${infra.websurfx.hostname}           IN HTTPS 1 . alpn="h3" ipv4hint="${infra.websurfx.ip}"
            ${infra.web-check.hostname}          IN HTTPS 1 . alpn="h3" ipv4hint="${infra.web-check.ip}"
            ${infra.wiki-go.hostname}            IN HTTPS 1 . alpn="h3" ipv4hint="${infra.wiki-go.ip}"
            ${infra.zipline.hostname}            IN HTTPS 1 . alpn="h3" ipv4hint="${infra.zipline.ip}"
            _autodiscover._tcp                   IN SRV 0 0 443 ${infra.autoconfig.user.fqdn}.
            _imap._tcp                           IN SRV 0 0 143 ${infra.imap.user.fqdn}.
            _matrix._tcp                         IN SRV 0 0 443 ${infra.matrix.fqdn}.
            _caldav._tcp	                 IN SRV 0 0 443 ${infra.caldav.fqdn}.
            _caldav._tcp                         IN TXT "path=/"
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
            ${infra.dns.fqdn}                    IN A  ${infra.dns.ip}
            ${infra.srv.hostname}                IN A  ${infra.srv.remote.ip}
          '';
        };
        "${infra.domain.virtual}" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${infra.domain.virtual}" ''
            $ORIGIN ${infra.domain.virtual}.
            $TTL    1h
            @ IN SOA ${infra.dns.fqdn}. ${infra.dns.contact}. (
                                           1    ; Serial
                                           3h   ; Refresh
                                           1h   ; Retry
                                           1w   ; Expire
                                           1h)  ; Negative Cache TTL
                                                 IN NS ${infra.dns.fqdn}.
            ${infra.dns.fqdn}                    IN A  ${infra.dns.ip}
            ${infra.srv.hostname}                IN A  ${infra.srv.virtual.ip}
          '';
        };
        "${toString infra.id.admin}.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${toString infra.id.admin}.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa" ''
            $ORIGIN ${toString infra.id.admin}.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa.
            $TTL    1h
            @ IN SOA ${infra.dns.fqdn}. ${infra.dns.contact}. (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                                                    IN NS  ${infra.dns.fqdn}.
            ${infra.dns.fqdn}                       IN A   ${infra.dns.ip}
            ${toString infra.imap.id}               IN PTR ${infra.imap.admin.fqdn}.
            ${toString infra.smtp.id}               IN PTR ${infra.smtp.admin.fqdn}.
            ${toString infra.webacme.id}            IN PTR ${infra.webacme.fqdn}.
            ${toString infra.webpki.id}             IN PTR ${infra.webpki.fqdn}.
          '';
        };
        "${toString infra.id.user}.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa" = {
          master = true;
          slaves = [infra.dns.ip];
          allowQuery = infra.dns.accessArray;
          file = pkgs.writeText "${toString infra.id.user}.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa" ''
            $ORIGIN ${toString infra.id.user}.${toString infra.site.networkrange.oct2}.${toString infra.site.networkrange.oct1}.in-addr.arpa.
            $TTL    1h
            @ IN SOA ${infra.dns.fqdn}. ${infra.dns.contact}. (
                                             1    ; Serial
                                             3h   ; Refresh
                                             1h   ; Retry
                                             1w   ; Expire
                                             1h)  ; Negative Cache TTL
                                                    IN NS  ${infra.dns.fqdn}.
            ${infra.dns.fqdn}                       IN A   ${infra.dns.ip}
            ${toString infra.autoconfig.id}         IN PTR ${infra.autoconfig.user.fqdn}.
            ${toString infra.bentopdf.id}           IN PTR ${infra.bentopdf.fqdn}.
            ${toString infra.cache.id}              IN PTR ${infra.cache.fqdn}.
            ${toString infra.chef.id}               IN PTR ${infra.chef.fqdn}.
            ${toString infra.ente.id}               IN PTR ${infra.ente.fqdn}.
            ${toString infra.erpnext.id}            IN PTR ${infra.erpnext.fqdn}.
            ${toString infra.iam.id}                IN PTR ${infra.iam.fqdn}.
            ${toString infra.it.id}                 IN PTR ${infra.it.fqdn}.
            ${toString infra.imap.id}               IN PTR ${infra.imap.user.fqdn}.
            ${toString infra.immich.id}             IN PTR ${infra.immich.fqdn}.
            ${toString infra.ldap.id}               IN PTR ${infra.ldap.fqdn}.
            ${toString infra.navidrome.id}          IN PTR ${infra.navidrome.fqdn}.
            ${toString infra.nextcloud.id}          IN PTR ${infra.nextcloud.fqdn}.
            ${toString infra.networking-toolbox.id} IN PTR ${infra.networking-toolbox.fqdn}.
            ${toString infra.miniflux.id}           IN PTR ${infra.miniflux.fqdn}.
            ${toString infra.pki.id}                IN PTR ${infra.pki.fqdn}.
            ${toString infra.portal.id}             IN PTR ${infra.portal.fqdn}.
            ${toString infra.search.id}             IN PTR ${infra.search.fqdn}.
            ${toString infra.sso.id}                IN PTR ${infra.sso.fqdn}.
            ${toString infra.smtp.id}               IN PTR ${infra.smtp.user.fqdn}.
            ${toString infra.test.id}               IN PTR ${infra.test.fqdn}.
            ${toString infra.portal.id}             IN PTR ${infra.portal.fqdn}.
            ${toString infra.res.id}                IN PTR ${infra.res.fqdn}.
            ${toString infra.translate.id}          IN PTR ${infra.translate.fqdn}.
            ${toString infra.vault.id}              IN PTR ${infra.vault.fqdn}.
            ${toString infra.vaultls.id}            IN PTR ${infra.vaultls.fqdn}.
            ${toString infra.webarchiv.id}          IN PTR ${infra.webarchiv.fqdn}.
            ${toString infra.webmail.id}            IN PTR ${infra.webmail.fqdn}.
            ${toString infra.web-check.id}          IN PTR ${infra.webmail.fqdn}.
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
