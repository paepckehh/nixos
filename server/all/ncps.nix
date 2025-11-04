# nixos/cache => services.ncps nixos binary cache (build/sign/cache)
# generated pubkey url = "https://${infra.cache.fqdn}/pubkey"
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
  networking.extraHosts = "${infra.cache.ip} ${infra.cache.hostname} ${infra.cache.fqdn}.";

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.ncps = {};
    users = {
      ncps = {
        group = "ncps";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ncps = {
      enable = true;
      cache = {
        hostName = infra.cache.hostname;
        maxSize = "50G";
        lru.schedule = "0 4 * * *"; # cleanup cache daily at 04:00
        allowPutVerb = false;
        allowDeleteVerb = false;
      };
      server.addr = "${infra.localhost.ip}:${toString infra.cache.localbind.port.http}";
      upstream = {
        caches = ["https://cache.nixos.org"];
        publicKeys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
      };
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "${infra.cache.fqdn}".extraConfig = ''
          bind ${infra.cache.ip}
          reverse_proxy ${infra.localhost.ip}:${toString infra.cache.localbind.port.http}
          tls ${infra.pki.acme.contact} {
                ca_root ${infra.pki.certs.rootCA.path}
                ca ${infra.pki.acme.url}
          }
          @not_intranet {
            not remote_ip ${infra.cache.access.cidr}
          }
          respond @not_intranet 403
          log {
            output file ${config.services.caddy.logDir}/access/${infra.cache.name}.log
          }'';
      };
    };
  };
}
