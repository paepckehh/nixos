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
  infra = (import ../../siteconfig/config.nix).infra;
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

  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../client/addCache.nix # self
  ];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ncps = {
      enable = true;
      prometheus.enable = false; # XXX
      logLevel = "info"; # "trace", "debug", "info", "warn", "error", "fatal", "panic"
      server.addr = "${infra.localhost.ip}:${toString infra.cache.localbind.port.http}";
      cache = {
        hostName = infra.cache.hostname;
        maxSize = infra.cache.size;
        allowPutVerb = lib.mkForce false;
        allowDeleteVerb = lib.mkForce false;
        lru.schedule = "10 10 * * *"; # cleanup cache daily 10:10
      };
      upstream = {
        caches = lib.mkForce [
          "https://cache.nixos.org"
        ];
        publicKeys = lib.mkForce [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    };
    caddy.virtualHosts."${infra.cache.fqdn}" = {
      listenAddresses = [infra.cache.ip];
      extraConfig = ''import intraproxy ${toString infra.cache.localbind.port.http}'';
    };
  };
}
